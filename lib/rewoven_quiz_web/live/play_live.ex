defmodule RewovenQuizWeb.PlayLive do
  use RewovenQuizWeb, :live_view

  alias RewovenQuiz.GameServer

  @impl true
  def mount(params, _session, socket) do
    socket = assign(socket, :page_title, "Join Game")
    player_id = generate_id()
    code = params["code"]

    socket = assign(socket,
      player_id: player_id,
      code: code || "",
      name: "",
      phase: :join,
      current_question: nil,
      selected_answer: nil,
      result: nil,
      reveal_data: nil,
      score: 0,
      streak: 0,
      leaderboard: [],
      error: nil
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("join", %{"code" => code, "name" => name}, socket) do
    code = String.trim(code)
    name = String.trim(name)

    cond do
      String.length(code) != 6 ->
        {:noreply, assign(socket, error: "Enter a 6-digit game PIN")}
      String.length(name) == 0 ->
        {:noreply, assign(socket, error: "Enter your name")}
      not GameServer.exists?(code) ->
        {:noreply, assign(socket, error: "Game not found")}
      true ->
        case GameServer.join(code, socket.assigns.player_id, name) do
          {:ok, state} ->
            Phoenix.PubSub.subscribe(RewovenQuiz.PubSub, "game:#{code}")
            phase = if state.phase == :lobby, do: :waiting, else: :waiting
            {:noreply, assign(socket, code: code, name: name, phase: phase, error: nil)}
          {:error, _} ->
            {:noreply, assign(socket, error: "Could not join game")}
        end
    end
  end

  def handle_event("answer", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    if socket.assigns.selected_answer != nil do
      {:noreply, socket}
    else
      case GameServer.answer(socket.assigns.code, socket.assigns.player_id, index) do
        {:ok, result} ->
          {:noreply, assign(socket,
            selected_answer: index,
            result: result,
            score: socket.assigns.score + result.points,
            streak: result.streak
          )}
        {:error, _} ->
          {:noreply, socket}
      end
    end
  end

  # PubSub handlers
  @impl true
  def handle_info({:player_joined, _pid, _name, _count}, socket) do
    {:noreply, socket}
  end

  def handle_info({:new_question, _index, question_data}, socket) do
    {:noreply, assign(socket,
      phase: :question,
      current_question: question_data,
      selected_answer: nil,
      result: nil,
      reveal_data: nil
    )}
  end

  def handle_info({:player_answered, _pid, _answered, _total}, socket) do
    {:noreply, socket}
  end

  def handle_info({:reveal, reveal_data}, socket) do
    {:noreply, assign(socket, phase: :reveal, reveal_data: reveal_data)}
  end

  def handle_info({:game_finished, leaderboard}, socket) do
    my_entry = Enum.find(leaderboard, fn e -> e.id == socket.assigns.player_id end)
    _my_rank = Enum.find_index(leaderboard, fn e -> e.id == socket.assigns.player_id end)
    score = if my_entry, do: my_entry.score, else: socket.assigns.score

    {:noreply, assign(socket, phase: :finished, leaderboard: leaderboard, score: score)}
  end

  defp generate_id, do: :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="quiz-player">
      <%= case @phase do %>
        <% :join -> %>
          <div class="join-screen">
            <h1>Join Quiz</h1>
            <p class="subtitle">Enter the game PIN shown on the host screen</p>
            <form phx-submit="join" class="join-form">
              <input name="code" value={@code} placeholder="Game PIN" maxlength="6"
                     inputmode="numeric" autocomplete="off" class="pin-input" />
              <input name="name" value={@name} placeholder="Your name" maxlength="20"
                     autocomplete="off" class="name-input" />
              <%= if @error do %>
                <p class="error-msg"><%= @error %></p>
              <% end %>
              <button type="submit" class="btn-join">Join</button>
            </form>
          </div>

        <% :waiting -> %>
          <div class="waiting-screen">
            <div class="waiting-icon">&#9989;</div>
            <h2>You're in!</h2>
            <p class="player-name"><%= @name %></p>
            <p class="waiting-text">Waiting for the host to start...</p>
          </div>

        <% :question -> %>
          <div class="question-screen-player">
            <div class="p-header">
              <span class="p-score"><%= @score %> pts</span>
              <span class="p-streak"><%= if @streak > 1, do: "#{@streak} streak" %></span>
            </div>
            <div class="p-question">
              <span class={"diff-badge #{@current_question.difficulty}"}><%= @current_question.difficulty %></span>
              <h2><%= @current_question.question %></h2>
            </div>
            <div class="p-answers">
              <%= for {opt, i} <- Enum.with_index(@current_question.options) do %>
                <button
                  phx-click="answer"
                  phx-value-index={i}
                  class={"p-answer-btn p-a#{i} #{if @selected_answer == i, do: "selected"} #{if @selected_answer != nil && @selected_answer != i, do: "dimmed"}"}
                  disabled={@selected_answer != nil}
                >
                  <%= opt %>
                </button>
              <% end %>
            </div>
            <%= if @result do %>
              <div class={"result-banner #{if @result.correct, do: "correct", else: "wrong"}"}>
                <%= if @result.correct do %>
                  &#10003; +<%= @result.points %> points!
                <% else %>
                  &#10007; Wrong!
                <% end %>
              </div>
            <% end %>
          </div>

        <% :reveal -> %>
          <div class="reveal-screen-player">
            <%= if @result && @result.correct do %>
              <div class="big-result correct">&#10003;</div>
              <h2>Correct!</h2>
              <p class="pts-earned">+<%= @result.points %> points</p>
            <% else %>
              <div class="big-result wrong">&#10007;</div>
              <h2>Wrong!</h2>
            <% end %>
            <p class="total-score"><%= @score %> total points</p>
            <%= if @reveal_data do %>
              <p class="p-explanation"><%= @reveal_data.explanation %></p>
            <% end %>
          </div>

        <% :finished -> %>
          <div class="finished-screen-player">
            <h1>&#127942; Game Over!</h1>
            <p class="your-score"><%= @score %> points</p>
            <div class="final-leaderboard">
              <%= for {entry, rank} <- Enum.with_index(@leaderboard, 1) do %>
                <div class={"lb-row #{if entry.id == @player_id, do: "you"}"}>
                  <span class="lb-rank"><%= case rank do; 1 -> "🥇"; 2 -> "🥈"; 3 -> "🥉"; n -> n; end %></span>
                  <span class="lb-name"><%= entry.name %><%= if entry.id == @player_id, do: " (you)" %></span>
                  <span class="lb-score"><%= entry.score %></span>
                </div>
              <% end %>
            </div>
          </div>
      <% end %>
    </div>
    """
  end
end
