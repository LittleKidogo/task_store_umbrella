defmodule TaskStore.RouterTest do 
    use ExUnit.Case, async: true

    @tag :distributed
    test "routes requests across nodes" do
        assert TaskStore.Router.route("hello", Kernel, :node, []) == :foo@Dragon
        assert TaskStore.Router.route("wwwww", Kernel, :node, []) == :bar@Dragon    
    end 


    test "raises on unknown entries" do 
        assert_raise  RuntimeError, ~r/could not find entry/, fn ->
            TaskStore.Router.route(<<0>>, Kernel, :node, [])
        end 
    end 
end 