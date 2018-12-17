defmodule TaskStore.Registry do 
  @moduledoc """
  This module implements a client server that we use to monitor `TaskStore.TaskList` processes, enabling us to kill 
  two birds with 1 stone.
  1. We can name the TaskList processes so as to have human usable name ... e.g Shoppin, Gardening, Work,
  2. We can monitor TaskList agents to ensure that we always serve up to date state
  """
  use GenServer 
  alias TaskStore.{
    TaskList
  }
  ## Client API for the server 
  
  @doc """
  This function accepts a list of options that it uses when initializing out server
  """
  @spec start_link(list(any())) :: {:ok, pid()} | {:error, any()}
  def start_link(opts) do 
    GenServer.start_link(__MODULE__, :ok, opts)
  end 

  @doc """
  Looks up the `TaskStore.TaskList` pid using the name that in the server
  """
  @spec lookup(pid(), String.t()) :: {:ok, pid()} | :error
  def lookup(server, name) do 
    GenServer.call(server, {:lookup, name})
  end 

  @doc """
  Ensure a `TaskStore.TaskList` process that is used to store that particular list's state
  exists in the server 
  """
  @spec create(pid(), String.t()) :: :ok
  def create(server, task_list_name) do 
    GenServer.cast(server, {:create, task_list_name})
  end 


  ## Server Callbacks 
  @doc """
  Initializes the server using passed in options 
  """
  @spec init(atom()) :: tuple()
  def init(:ok) do 
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end 

  @doc """
  Handles a synchrounous call to check for a `TaskStore.TaskList` pid using a string name 
  """
  @spec handle_call(tuple(), pid(), map()) :: tuple()
  def handle_call({:lookup, name}, _from, {names, _} = state) do 
    {:reply, Map.fetch(names, name), state}
  end 

  @doc """
  Handles an asynchronous cast the create a `TaskStore.TaskList` and store the name and pid in the server 
  """
  @spec handle_cast(tuple(), map()) :: tuple()
  def handle_cast({:create, name}, {names, refs}) do 
    if Map.has_key?(names, name) do 
      {:noreply, names}
    else 
      {:ok, task_list} = TaskList.start_link([])
      ref = Process.monitor(task_list)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, task_list)
      {:noreply, {names, refs}}
    end 
  end 

  @doc """
  Handles an incoming message that signifies a bucket has just crashed, this enables us to clean up our state
  and only serve relevant items 
  """
  @spec handle_info(tuple(), tuple()) :: tuple()
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do 
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @doc """
  Handle unknown messages to ensure the process mailbox doesnt overflow 
  """
  def handle_info(_, state), do: {:noreply, state} 
end 
