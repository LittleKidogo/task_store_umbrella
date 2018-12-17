defmodule TaskStoreTest do
  # Inject the ExUnit testing api to this module
  use ExUnit.Case
  doctest TaskStore

  test "greets the world" do
    assert TaskStore.hello() == :world
  end
end
