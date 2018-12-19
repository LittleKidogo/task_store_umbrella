defmodule TaskStore.TaskListTest do 
  @moduledoc """
  This module contains unit tests used to test the functions in the TaskList Boundary module
  """
  use ExUnit.Case, async: true
  alias TaskStore.{
    TaskList
  }

  setup do 
    {:ok, task_list} = TaskList.start_link([])
    %{task_list: task_list}
  end 

  @task "finish gardening"
  @task_time  "11am - 12pm"
  test "stores a task by its label", %{task_list: task_list} do 
    
    assert TaskList.get(task_list, "finish gardening") == nil 

    TaskList.put(task_list, "finish gardening", "11am - 12pm")
    assert TaskList.get(task_list, "finish gardening") == "11am - 12pm" 
  end

  test "deletes a task by its label", %{task_list: task_list} do 
    TaskList.put(task_list, @task, @task_time)
    assert TaskList.get(task_list, @task) == @task_time

    TaskList.delete(task_list, @task) 

    assert TaskList.get(task_list, @task) == nil
  end

  test "are temporary workers" do 
    assert Supervisor.child_spec(TaskList, []).restart == :temporary
  end   
end 
