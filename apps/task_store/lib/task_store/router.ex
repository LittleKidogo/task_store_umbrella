defmodule TaskStore.Router do 
    @moduledoc """
    This module holds the routing functionality used to distriute commands to the correct node to handle them
    """

    @doc """
    Dispatch the given `mod`, `fun`, `args` request
    to the appropriate node based on the `task_list`
    """
    def route(task_list, mod, fun, args) do
        # get first byte  from the task list name  
        first = :binary.first(task_list)

        # find the relevant entry in the table or raise 
        entry = 
            Enum.find(table(), fn {enum, _node} ->
                first in enum 
            end) || no_entry_error(task_list)

        # in the entry node is in the current node 
        if elem(entry, 1) == node() do 
            apply(mod, fun, args)
        else 
            {TaskStore.RouterTasks, elem(entry, 1)}
            |> Task.Supervisor.async(TaskStore.Router, :route, [task_list, mod, fun, args])
            |> Task.await()
        end 
    end

    defp no_entry_error(task_list) do
        raise "could not find entry for #{inspect task_list} in table #{inspect table()}"
    end 

    @doc """
    The routing table.
    """
    def table do
        Application.fetch_env!(:task_store, :routing_table)
    end 
end 