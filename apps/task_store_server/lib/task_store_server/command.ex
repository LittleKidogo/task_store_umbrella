defmodule TaskStoreServer.Command do
  @moduledoc """
  This module parses commands from clients for the `TaskStoreServer` application
  """
  alias TaskStore.TaskList

  @doc ~S"""
  Parses the given `line` from a client to a command for the `TaskStore` application 

  ## Examples 

      iex> TaskStoreServer.Command.parse("CREATE gardening\r\n")
      {:ok, {:create, "gardening"}}

      iex> TaskStoreServer.Command.parse("CREATE gardening  \r\n")
      {:ok, {:create, "gardening"}}

      iex> TaskStoreServer.Command.parse("PUT gardening cut-grass 12pm-1pm\r\n")
      {:ok, {:put, "gardening", "cut-grass", "12pm-1pm"}}

      iex> TaskStoreServer.Command.parse("GET gardening cut-grass\r\n")
      {:ok, {:get, "gardening", "cut-grass"}}
      
      iex> TaskStoreServer.Command.parse("DELETE gardening cut-grass\r\n")
      {:ok, {:delete, "gardening", "cut-grass"}}

  Unknown commands should error out 

      iex> TaskStoreServer.Command.parse("WHATEVER gardening\r\n")
      {:error, :unknown_command}

      iex> TaskStoreServer.Command.parse("CREATE gardening now\r\n")
      {:error, :unknown_command}

  """
  @spec parse(String.t()) :: {atom(), tuple()} | {atom(), atom()}
  def parse(line) do
    case String.split(line) do
      ["CREATE", task_list_name] -> {:ok, {:create, task_list_name}}
      ["GET", task_list, task] -> {:ok, {:get, task_list, task}}
      ["PUT", task_list, task, task_time] -> {:ok, {:put, task_list, task, task_time}}
      ["DELETE", task_list, task] -> {:ok, {:delete, task_list, task}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command against task store
  """
  @spec run(tuple()) :: any()
  def run(command)

  def run({:create, task_list}) do
    TaskStore.Registry.create(TaskStore.Registry, task_list)
    {:ok, "OK\r\n"}
  end

  def run({:get, task_list, key}) do
    lookup(task_list, fn pid ->
      value = TaskList.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:put, task_list, task, task_time}) do
    lookup(task_list, fn pid ->
      TaskList.put(pid, task, task_time)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:delete, task_list, task}) do
    lookup(task_list, fn pid ->
      TaskList.delete(pid, task)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(task_list, callback) do
    case TaskStore.Registry.lookup(TaskStore.Registry, task_list) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
