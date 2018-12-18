defmodule TaskStore.TaskList do 
  @moduledoc """
  This module handles interaction with task lists in the `TaskStore` application 
  use this module to create new task lists update them and delete them :)
  """
  use Agent, restart: :temporary

  @doc """
  Starts a new task list
  """
  @spec start_link(list(any())) :: {:ok, pid()} | {:error, any()}
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a task from the TaskList by the name of the task 
  """
  @spec get(pid(), String.t()) :: String.t() | nil 
  def get(task_list, name) do 
    Agent.get(task_list, &Map.get(&1, name))
  end

  @doc """
  Add a task to a task list 
  """
  @spec put(pid(), String.t(), String.t()) :: :ok | :error
  def put(task_list, task, time) do 
    Agent.update(task_list, &Map.put(&1, task, time))
  end 

  @doc """
  Deletes a task from a task list
  """
  @spec delete(pid(), String.t()) :: String.t() | any()
  def delete(task_list, task) do 
    Agent.get_and_update(task_list, &Map.pop(&1, task))
  end 
end   
