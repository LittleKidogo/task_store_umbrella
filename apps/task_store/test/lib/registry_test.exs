defmodule TaskStore.RegistryTest do 
  @moduledoc """
  This module holds unit tests used to test the functions tin the `TaskStore.Registry` Boundart module 
  """
  use ExUnit.Case
  alias TaskStore.{
    Registry,
    TaskList
  }

  setup context do 
    # use start supervised to ensure that the process is shutdown before the next test 
    _ = start_supervised!({Registry, name: context.test})
    %{registry: context.test}
  end 

  @task_list "shopping"
  @task "milk"
  @task_time  "7am - 8am"
  describe "TaskStore Registry" do
    test "spawns a task list and labels it", %{registry: registry} do 
      assert Registry.lookup(registry, @task_list) == :error

      Registry.create(registry, @task_list)
      assert {:ok, task_list} = Registry.lookup(registry, @task_list)

      TaskList.put(task_list, @task, @task_time)
      assert TaskList.get(task_list, @task) == @task_time
    end 

    test "removes task_list on exit", %{registry: registry} do 
      Registry.create(registry, @task_list)
      {:ok, task_list} = Registry.lookup(registry, @task_list)
      Agent.stop(task_list)
      Registry.create(registry, "not_used")
      assert Registry.lookup(registry, @task_list) == :error
    end

    test "removed task_list on crash", %{registry: registry} do 
      Registry.create(registry, @task_list)
      {:ok, task_list} = Registry.lookup(registry, @task_list)

      # muahahaha crash the TaskList 
      Agent.stop(task_list, :shutdown)
      Registry.create(registry, "not_used")
      assert Registry.lookup(registry, @task_list) == :error
    end  

    @tag :capture_log
    test "task_list can crash any time", %{registry: registry} do 
      Registry.create(registry, @task_list)
      {:ok, task_list} = Registry.lookup(registry, @task_list)

      # Simulate a task list crash 
      Agent.stop(task_list, :crash)

      catch_exit TaskList.put(task_list, @task, @task_time)
    end 
  end 
end 
