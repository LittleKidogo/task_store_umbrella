defmodule TaskStoreServerTest do
  use ExUnit.Case
  doctest TaskStoreServer

  test "greets the world" do
    assert TaskStoreServer.hello() == :world
  end
end
