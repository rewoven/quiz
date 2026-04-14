defmodule RewovenQuiz.GameServer do
  @moduledoc "GenServer managing a single game room's state, timer, and scoring."
  use GenServer

  alias RewovenQuiz.Questions

  @time_limit 15_000  # 15 seconds per question
  @max_points 1000

  # ─── Public API ───

  def start_link(opts) do
    code = Keyword.fetch!(opts, :code)
    GenServer.start_link(__MODULE__, opts, name: via(code))
  end

  def via(code), do: {:via, Registry, {RewovenQuiz.GameRegistry, code}}

  def join(code, player_id, name) do
    GenServer.call(via(code), {:join, player_id, name})
  end

  def start_game(code) do
    GenServer.call(via(code), :start_game)
  end

  def answer(code, player_id, answer_index) do
    GenServer.call(via(code), {:answer, player_id, answer_index})
  end

  def next_question(code) do
    GenServer.call(via(code), :next_question)
  end

  def get_state(code) do
    GenServer.call(via(code), :get_state)
  end

  def reveal(code) do
    GenServer.call(via(code), :reveal)
  end

  def exists?(code) do
    case Registry.lookup(RewovenQuiz.GameRegistry, code) do
      [{_pid, _}] -> true
      [] -> false
    end
  end

  # ─── GenServer callbacks ───

  @impl true
  def init(opts) do
    code = Keyword.fetch!(opts, :code)
    host_id = Keyword.fetch!(opts, :host_id)
    category = Keyword.get(opts, :category, "all")
    question_count = Keyword.get(opts, :question_count, 15)

    questions = Questions.pick(question_count, category)

    state = %{
      code: code,
      host_id: host_id,
      category: category,
      phase: :lobby,           # :lobby | :question | :reveal | :leaderboard | :finished
      players: %{},            # player_id => %{name, score, streak, best_streak, correct, answers}
      questions: questions,
      current_index: 0,
      answers_this_round: %{}, # player_id => %{answer, time_ms, correct, points}
      timer_ref: nil,
      question_started_at: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:join, player_id, name}, _from, state) do
    if state.phase != :lobby and state.phase != :question and state.phase != :reveal and state.phase != :leaderboard do
      {:reply, {:error, :game_finished}, state}
    else
      player = Map.get(state.players, player_id, %{
        name: name, score: 0, streak: 0, best_streak: 0, correct: 0, answers: []
      })
      # Update name in case they rejoin
      player = %{player | name: name}
      new_state = put_in(state.players[player_id], player)
      broadcast(state.code, {:player_joined, player_id, name, map_size(new_state.players)})
      {:reply, {:ok, new_state}, new_state}
    end
  end

  @impl true
  def handle_call(:start_game, _from, %{phase: :lobby} = state) do
    if map_size(state.players) == 0 do
      {:reply, {:error, :no_players}, state}
    else
      new_state = start_question(state)
      {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call(:start_game, _from, state) do
    {:reply, {:error, :already_started}, state}
  end

  @impl true
  def handle_call({:answer, player_id, answer_index}, _from, %{phase: :question} = state) do
    # Don't allow double answers
    if Map.has_key?(state.answers_this_round, player_id) do
      {:reply, {:error, :already_answered}, state}
    else
      question = Enum.at(state.questions, state.current_index)
      elapsed = System.monotonic_time(:millisecond) - state.question_started_at
      is_correct = answer_index == question.correct

      # Calculate points (Kahoot-style: faster = more points)
      {points, new_streak} = if is_correct do
        time_fraction = max(0, (@time_limit - elapsed) / @time_limit)
        diff_mult = case question.difficulty do
          :hard -> 1.5
          :medium -> 1.2
          :easy -> 1.0
        end
        base_points = round(@max_points * time_fraction * diff_mult)
        player = state.players[player_id]
        new_streak = player.streak + 1
        streak_mult = cond do
          new_streak >= 5 -> 1.5
          new_streak >= 3 -> 1.2
          true -> 1.0
        end
        {round(base_points * streak_mult), new_streak}
      else
        {0, 0}
      end

      # Update player
      player = state.players[player_id]
      player = %{player |
        score: player.score + points,
        streak: new_streak,
        best_streak: max(player.best_streak, new_streak),
        correct: player.correct + (if is_correct, do: 1, else: 0)
      }

      round_answer = %{answer: answer_index, time_ms: elapsed, correct: is_correct, points: points}

      new_state = state
        |> put_in([:players, player_id], player)
        |> put_in([:answers_this_round, player_id], round_answer)

      broadcast(state.code, {:player_answered, player_id, map_size(new_state.answers_this_round), map_size(state.players)})

      # If all players answered, auto-reveal
      new_state = if map_size(new_state.answers_this_round) == map_size(new_state.players) do
        cancel_timer(new_state)
        |> do_reveal()
      else
        new_state
      end

      {:reply, {:ok, %{correct: is_correct, points: points, streak: new_streak}}, new_state}
    end
  end

  def handle_call({:answer, _player_id, _answer}, _from, state) do
    {:reply, {:error, :not_in_question_phase}, state}
  end

  @impl true
  def handle_call(:reveal, _from, %{phase: :question} = state) do
    new_state = cancel_timer(state) |> do_reveal()
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call(:reveal, _from, state) do
    {:reply, {:error, :not_in_question_phase}, state}
  end

  @impl true
  def handle_call(:next_question, _from, %{phase: phase} = state) when phase in [:reveal, :leaderboard] do
    next_idx = state.current_index + 1
    if next_idx >= length(state.questions) do
      new_state = %{state | phase: :finished}
      broadcast(state.code, {:game_finished, leaderboard(new_state)})
      {:reply, {:ok, new_state}, new_state}
    else
      new_state = %{state | current_index: next_idx}
        |> start_question()
      {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call(:next_question, _from, state) do
    {:reply, {:error, :wrong_phase}, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, sanitize(state)}, state}
  end

  # Timer expired
  @impl true
  def handle_info(:time_up, %{phase: :question} = state) do
    new_state = do_reveal(state)
    {:noreply, new_state}
  end

  def handle_info(:time_up, state), do: {:noreply, state}

  # ─── Private ───

  defp start_question(state) do
    question = Enum.at(state.questions, state.current_index)
    timer_ref = Process.send_after(self(), :time_up, @time_limit)

    new_state = %{state |
      phase: :question,
      answers_this_round: %{},
      timer_ref: timer_ref,
      question_started_at: System.monotonic_time(:millisecond)
    }

    broadcast(state.code, {:new_question, state.current_index, %{
      question: question.question,
      options: question.options,
      difficulty: question.difficulty,
      category: question.category,
      index: state.current_index,
      total: length(state.questions)
    }})

    new_state
  end

  defp do_reveal(state) do
    question = Enum.at(state.questions, state.current_index)

    new_state = %{state | phase: :reveal, timer_ref: nil}

    broadcast(state.code, {:reveal, %{
      correct: question.correct,
      explanation: question.explanation,
      answers: state.answers_this_round,
      leaderboard: leaderboard(new_state) |> Enum.take(5)
    }})

    new_state
  end

  defp cancel_timer(%{timer_ref: nil} = state), do: state
  defp cancel_timer(%{timer_ref: ref} = state) do
    Process.cancel_timer(ref)
    %{state | timer_ref: nil}
  end

  defp leaderboard(state) do
    state.players
    |> Enum.map(fn {id, p} -> %{id: id, name: p.name, score: p.score, correct: p.correct, streak: p.best_streak} end)
    |> Enum.sort_by(& &1.score, :desc)
  end

  defp sanitize(state) do
    current_q = if state.phase == :question do
      q = Enum.at(state.questions, state.current_index)
      %{question: q.question, options: q.options, difficulty: q.difficulty, category: q.category}
    else
      nil
    end

    %{
      code: state.code,
      phase: state.phase,
      players: Enum.map(state.players, fn {id, p} -> {id, %{name: p.name, score: p.score}} end) |> Map.new(),
      current_index: state.current_index,
      total_questions: length(state.questions),
      current_question: current_q,
      answers_count: map_size(state.answers_this_round),
      leaderboard: leaderboard(state)
    }
  end

  defp broadcast(code, message) do
    Phoenix.PubSub.broadcast(RewovenQuiz.PubSub, "game:#{code}", message)
  end
end
