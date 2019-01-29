defmodule Scores do
  def start do
    Agent.start_link(fn -> %{lifetime_score: 0, current_score: 0, last_played: "never"} end)
  end

  def put(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
    overall_score(pid, key, value)
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def show(pid) do
    Agent.get(pid, fn state -> state end)
  end

  defp overall_score(pid,key, value) do
    case key do
      :current_score ->
        last_played = Agent.get(pid, &Map.get(&1, :current_score))

        overall_score = Agent.get(pid, &Map.get(&1, :lifetime_score)) + value
        IO.puts("overall = #{overall_score}\n value = #{value}\n last_played = #{last_played}")

        # update state
        Agent.update(pid, &Map.put(&1, :lifetime_score, overall_score))
        Agent.update(pid, &Map.put(&1, :last_played, last_played))


      _ ->

    end
  end
end
