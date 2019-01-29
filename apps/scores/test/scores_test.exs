defmodule ScoresTest do
  use ExUnit.Case, async: true
  alias Scores

  setup do
    {:ok, stats} = Scores.start()
    %{stats: stats}
  end

  test "starts the scores server", %{stats: stats} do
    assert is_pid(stats)
  end

  test " initializes state", %{stats: stats} do
    assert Scores.show(stats) == %{
             score: 0,
             best_score: 0,
             previous_score: "never played",
             lifetime_score: 0
           }
  end

  test "put/3 adds a key value score to state", %{stats: stats} do
    assert Scores.put(stats, :player_name, "ricoh") == :ok
  end

  test "show/1 displays all contents of state", %{stats: stats} do
    assert Scores.put(stats, :player_name, "ricoh") == :ok

    assert Scores.show(stats) == %{
             score: 0,
             previous_score: 0,
             lifetime_score: 0,
             best_score: 0,
             player_name: "ricoh"
           }
  end

  test "get/2 retrieves the value of given key from the state", %{stats: stats} do
    assert Scores.get(stats, :previous_score) == "never played"
  end

  test "calculates and updates total lifetime scores", %{stats: stats} do
    assert Scores.put(stats, :score, 23) == :ok
    assert Scores.put(stats, :score, 939) == :ok
    assert Scores.put(stats, :score, 34) == :ok
    assert Scores.get(stats, :lifetime_score) == 996
  end

  test "updates the scores of the previous round", %{stats: stats} do
    assert Scores.put(stats, :score, 23) == :ok
    assert Scores.put(stats, :score, 939) == :ok
    assert Scores.get(stats, :previous_score) == 23
    assert Scores.put(stats, :score, 34) == :ok
    assert Scores.get(stats, :previous_score) == 939
  end

  test "track best score after several rounds", %{stats: stats} do
    assert Scores.put(stats, :score, 23) == :ok
    assert Scores.put(stats, :score, 939) == :ok
    assert Scores.put(stats, :score, 34) == :ok
    assert Scores.get(stats, :best_score) == 939
  end
end
