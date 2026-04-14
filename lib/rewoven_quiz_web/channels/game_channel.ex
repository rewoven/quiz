defmodule RewovenQuizWeb.GameChannel do
  @moduledoc "Phoenix Channel for real-time game communication between players."
  use RewovenQuizWeb, :channel

  alias RewovenQuiz.GameServer

  @impl true
  def join("game:" <> code, %{"name" => name, "player_id" => player_id}, socket) do
    if GameServer.exists?(code) do
      case GameServer.join(code, player_id, name) do
        {:ok, state} ->
          socket = socket
            |> assign(:code, code)
            |> assign(:player_id, player_id)
            |> assign(:name, name)

          # Subscribe to PubSub for game broadcasts
          Phoenix.PubSub.subscribe(RewovenQuiz.PubSub, "game:#{code}")

          send(self(), :after_join)
          {:ok, %{phase: state.phase, players: map_size(state.players)}, socket}

        {:error, reason} ->
          {:error, %{reason: reason}}
      end
    else
      {:error, %{reason: "Game not found"}}
    end
  end

  def join("game:" <> _code, _params, _socket) do
    {:error, %{reason: "Missing name or player_id"}}
  end

  @impl true
  def handle_info(:after_join, socket) do
    case GameServer.get_state(socket.assigns.code) do
      {:ok, state} ->
        push(socket, "game_state", state)
      _ -> :ok
    end
    {:noreply, socket}
  end

  # Forward PubSub broadcasts to the channel
  def handle_info({:player_joined, player_id, name, count}, socket) do
    push(socket, "player_joined", %{player_id: player_id, name: name, count: count})
    {:noreply, socket}
  end

  def handle_info({:new_question, _index, question_data}, socket) do
    push(socket, "new_question", question_data)
    {:noreply, socket}
  end

  def handle_info({:player_answered, _player_id, answered, total}, socket) do
    push(socket, "answer_count", %{answered: answered, total: total})
    {:noreply, socket}
  end

  def handle_info({:reveal, reveal_data}, socket) do
    push(socket, "reveal", reveal_data)
    {:noreply, socket}
  end

  def handle_info({:game_finished, leaderboard}, socket) do
    push(socket, "game_finished", %{leaderboard: leaderboard})
    {:noreply, socket}
  end

  # Player submits an answer
  @impl true
  def handle_in("answer", %{"answer" => answer_index}, socket) do
    case GameServer.answer(socket.assigns.code, socket.assigns.player_id, answer_index) do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end
end
