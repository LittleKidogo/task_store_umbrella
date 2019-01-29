defmodule Scores do
  def start do
    Agent.start_link(fn ->
      %{score: 0, best_score: 0, previous_score: "never played", lifetime_score: 0}
    end)
  end

  def put(pid, key, value) do
    save_score(pid)
    Agent.update(pid, fn state -> Map.put(state, key, value) end)
    calculate_scores(pid, key, value)
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def show(pid) do
    Agent.get(pid, fn state -> state end)
  end

  defp calculate_scores(pid, key, value) do
    case key do
      :score ->
        overall_score = Agent.get(pid, &Map.get(&1, :lifetime_score)) + value
        best_score(pid, value)
        Agent.update(pid, &Map.put(&1, :lifetime_score, overall_score))

      _ ->
        :ok
    end
  end

  defp save_score(pid) do
    scores_bfr_update = Agent.get(pid, &Map.get(&1, :score))
    Agent.update(pid, &Map.put(&1, :previous_score, scores_bfr_update))
  end

  defp best_score(pid, value) do
    current_best_score = Agent.get(pid, fn state -> Map.get(state, :best_score) end)

    if is_integer(value) and current_best_score < value do
      Agent.update(pid, fn state -> Map.put(state, :best_score, value) end)
    end
  end
end
