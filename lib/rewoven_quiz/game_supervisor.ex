defmodule RewovenQuiz.GameSupervisor do
  @moduledoc "DynamicSupervisor for game room processes."
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc "Create a new game room. Returns {:ok, code} or {:error, reason}."
  def create_game(host_id, opts \\ []) do
    code = generate_code()
    category = Keyword.get(opts, :category, "all")
    question_count = Keyword.get(opts, :question_count, 15)

    child_spec = {RewovenQuiz.GameServer, [
      code: code,
      host_id: host_id,
      category: category,
      question_count: question_count
    ]}

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} -> {:ok, code}
      {:error, reason} -> {:error, reason}
    end
  end

  defp generate_code do
    code = :rand.uniform(999_999)
      |> Integer.to_string()
      |> String.pad_leading(6, "0")

    if RewovenQuiz.GameServer.exists?(code) do
      generate_code()
    else
      code
    end
  end
end
