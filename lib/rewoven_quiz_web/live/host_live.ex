defmodule RewovenQuizWeb.HostLive do
  use RewovenQuizWeb, :live_view

  alias RewovenQuiz.{GameSupervisor, GameServer, Questions}

  @impl true
  def mount(_params, session, socket) do
    socket = assign(socket, :page_title, "Host Game")
    host_id = session["host_id"] || generate_id()

    socket = assign(socket,
      host_id: host_id,
      code: nil,
      phase: :setup,
      players: %{},
      current_question: nil,
      current_index: 0,
      total_questions: 0,
      answers_count: 0,
      player_count: 0,
      leaderboard: [],
      reveal_data: nil,
      category: "all",
      question_count: "15",
      categories: Questions.categories()
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("create_game", %{"category" => category, "question_count" => qc}, socket) do
    count = String.to_integer(qc)
    case GameSupervisor.create_game(socket.assigns.host_id, category: category, question_count: count) do
      {:ok, code} ->
        Phoenix.PubSub.subscribe(RewovenQuiz.PubSub, "game:#{code}")
        {:noreply, assign(socket, code: code, phase: :lobby, category: category, question_count: qc)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to create game")}
    end
  end

  def handle_event("start_game", _, socket) do
    case GameServer.start_game(socket.assigns.code) do
      {:ok, _} -> {:noreply, socket}
      {:error, :no_players} -> {:noreply, put_flash(socket, :error, "Need at least 1 player")}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("reveal_answers", _, socket) do
    case GameServer.reveal(socket.assigns.code) do
      {:ok, _} -> {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("next_question", _, socket) do
    case GameServer.next_question(socket.assigns.code) do
      {:ok, _} -> {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("new_game", _, socket) do
    {:noreply, assign(socket, code: nil, phase: :setup, players: %{}, leaderboard: [], reveal_data: nil)}
  end

  # PubSub handlers
  @impl true
  def handle_info({:player_joined, player_id, name, count}, socket) do
    players = Map.put(socket.assigns.players, player_id, name)
    {:noreply, assign(socket, players: players, player_count: count)}
  end

  def handle_info({:new_question, index, question_data}, socket) do
    {:noreply, assign(socket,
      phase: :question,
      current_question: question_data,
      current_index: index,
      total_questions: question_data.total,
      answers_count: 0,
      reveal_data: nil
    )}
  end

  def handle_info({:player_answered, _pid, answered, _total}, socket) do
    {:noreply, assign(socket, answers_count: answered)}
  end

  def handle_info({:reveal, reveal_data}, socket) do
    {:noreply, assign(socket, phase: :reveal, reveal_data: reveal_data, leaderboard: reveal_data.leaderboard)}
  end

  def handle_info({:game_finished, leaderboard}, socket) do
    {:noreply, assign(socket, phase: :finished, leaderboard: leaderboard)}
  end

  defp generate_id, do: :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="quiz-host">
      <%= case @phase do %>
        <% :setup -> %>
          <div class="setup-screen" id="setup-screen">
            <!-- Premium gate (toggled by JS once Supabase reports premium status) -->
            <div id="premium-gate" style="display:block;">
              <h1>🔒 Premium feature</h1>
              <p class="subtitle">
                Hosting a multiplayer quiz is part of <strong>Rewoven Premium</strong>.
                Subscribe for $4.99/month to unlock it (plus the curriculum and unlimited fabric scans).
              </p>
              <a href="https://premium.rewovenapp.com" class="btn-create" style="display:inline-block; text-decoration:none; text-align:center;">
                Get Premium
              </a>
              <p style="margin-top:16px; font-size:14px; color:#6b7280;">
                Already a subscriber? <a href="#" id="check-premium-link" style="color:#059669; font-weight:600;">Refresh status</a>
              </p>
            </div>

            <!-- Real host UI (hidden until JS confirms premium) -->
            <div id="host-form" style="display:none;">
              <h1>Create a Quiz</h1>
              <p class="subtitle">Set up a multiplayer sustainability quiz for your group</p>
              <form phx-submit="create_game" class="setup-form">
              <label>Category</label>
              <select name="category">
                <option value="all">All Categories (Mix)</option>
                <%= for cat <- @categories do %>
                  <option value={cat}><%= cat %></option>
                <% end %>
              </select>

              <label>Number of Questions</label>
              <select name="question_count">
                <option value="10">10</option>
                <option value="15" selected>15</option>
                <option value="20">20</option>
                <option value="30">30</option>
              </select>

              <button type="submit" class="btn-create">Create Game</button>
              </form>
            </div>
          </div>

        <% :lobby -> %>
          <div class="lobby-screen">
            <div class="room-code-display">
              <span class="code-label">Game PIN</span>
              <span class="code-value"><%= @code %></span>
            </div>
            <p class="join-url">Go to <strong>/play</strong> and enter the PIN</p>
            <div class="player-list">
              <h3><%= @player_count %> Player<%= if @player_count != 1, do: "s" %></h3>
              <div class="player-chips">
                <%= for {_id, name} <- @players do %>
                  <span class="player-chip"><%= name %></span>
                <% end %>
              </div>
            </div>
            <button phx-click="start_game" class="btn-start" disabled={@player_count == 0}>
              Start Game
            </button>
          </div>

        <% :question -> %>
          <div class="question-screen">
            <div class="q-header">
              <span class="q-num"><%= @current_index + 1 %> / <%= @total_questions %></span>
              <span class="q-answers"><%= @answers_count %> / <%= @player_count %> answered</span>
            </div>
            <div class="q-card">
              <span class={"diff-badge #{@current_question.difficulty}"}><%= @current_question.difficulty %></span>
              <h2><%= @current_question.question %></h2>
            </div>
            <div class="options-display">
              <%= for {opt, i} <- Enum.with_index(@current_question.options) do %>
                <div class={"opt-block opt-#{i}"}><%= opt %></div>
              <% end %>
            </div>
            <button phx-click="reveal_answers" class="btn-reveal">
              Reveal Answers
            </button>
          </div>

        <% :reveal -> %>
          <div class="reveal-screen">
            <div class="q-card">
              <h2><%= @current_question.question %></h2>
            </div>
            <div class="options-display">
              <%= for {opt, i} <- Enum.with_index(@current_question.options) do %>
                <div class={"opt-block opt-#{i} #{if @reveal_data && i == @reveal_data.correct, do: "correct", else: "wrong"}"}>
                  <%= opt %>
                  <%= if @reveal_data && i == @reveal_data.correct do %>
                    <span class="check">&#10003;</span>
                  <% end %>
                </div>
              <% end %>
            </div>
            <%= if @reveal_data do %>
              <p class="explanation"><%= @reveal_data.explanation %></p>
            <% end %>
            <div class="mini-leaderboard">
              <h3>Leaderboard</h3>
              <%= for {entry, rank} <- Enum.with_index(@leaderboard, 1) do %>
                <div class="lb-row">
                  <span class="lb-rank"><%= rank %></span>
                  <span class="lb-name"><%= entry.name %></span>
                  <span class="lb-score"><%= entry.score %></span>
                </div>
              <% end %>
            </div>
            <button phx-click="next_question" class="btn-next">
              <%= if @current_index + 1 >= @total_questions, do: "See Final Results", else: "Next Question" %>
            </button>
          </div>

        <% :finished -> %>
          <div class="finished-screen">
            <h1>&#127942; Game Over!</h1>
            <div class="final-leaderboard">
              <%= for {entry, rank} <- Enum.with_index(@leaderboard, 1) do %>
                <div class={"lb-row final #{if rank <= 3, do: "top-#{rank}"}"}>
                  <span class="lb-rank"><%= case rank do; 1 -> "🥇"; 2 -> "🥈"; 3 -> "🥉"; n -> n; end %></span>
                  <span class="lb-name"><%= entry.name %></span>
                  <span class="lb-score"><%= entry.score %> pts</span>
                  <span class="lb-correct"><%= entry.correct %> correct</span>
                </div>
              <% end %>
            </div>
            <button phx-click="new_game" class="btn-create">New Game</button>
          </div>
      <% end %>
    </div>

    <script :if={@phase == :setup}>
      (() => {
        const SUPABASE_URL = document.body.dataset.supabaseUrl;
        const SUPABASE_KEY = document.body.dataset.supabaseAnonKey;
        const PREMIUM_URL  = document.body.dataset.premiumUrl || 'https://premium.rewovenapp.com';
        const REQUIRE_PREMIUM = document.body.dataset.requirePremium === 'true';

        const gate = document.getElementById('premium-gate');
        const form = document.getElementById('host-form');
        const refreshLink = document.getElementById('check-premium-link');

        const reveal = () => {
          if (gate) gate.style.display = 'none';
          if (form) form.style.display = 'block';
        };
        const lock = () => {
          if (gate) gate.style.display = 'block';
          if (form) form.style.display = 'none';
        };

        // Soft-launch: when REQUIRE_PREMIUM is false, everyone can host.
        if (!REQUIRE_PREMIUM) { reveal(); return; }

        if (!SUPABASE_URL || !SUPABASE_KEY || !window.supabase) {
          // Misconfigured — fall back to lock so we don't accidentally
          // give away premium features.
          lock();
          return;
        }

        const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

        const check = async () => {
          const { data: { user } } = await sb.auth.getUser();
          if (!user) { lock(); return; }
          const { data: profile } = await sb
            .from('profiles')
            .select('is_premium')
            .eq('id', user.id)
            .maybeSingle();
          if (profile?.is_premium) reveal(); else lock();
        };

        check();
        if (refreshLink) refreshLink.addEventListener('click', (e) => { e.preventDefault(); check(); });
      })();
    </script>
    """
  end
end
