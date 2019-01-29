defmodule ScoresTest do
  use ExUnit.Case, async: true
  alias Scores

  test "starts the scores server" do
    {:ok, pid} = Scores.start
    assert is_pid(pid)
  end

  test " initial scores is empty" do
    {:ok, pid} = Scores.start
    assert Scores.show(pid) == %{}
  end

  test "adds a key value score to state" do
    {:ok, pid} = Scores.start
    assert Scores.put(pid, :current_score, 10) == :ok
    assert Scores.show(pid) == %{current_score: 10}
  end

  test "gets the value of given key from the state" do
    {:ok, pid} = Scores.start
    assert Scores.put(pid, :current_score, 10) == :ok
    assert Scores.put(pid, :current_score, 219) == :ok
    assert Scores.get(pid, :lifetime_score) == 229
  end

end
