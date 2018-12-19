defmodule TaskStore.Supervisor do 
  @moduledoc """
  This module holds the implentation logic for the supervision tree ued to handle the Registry Process
  """
  use Supervisor

  @doc """
  This function starts a supervisor in charge of monitoring a few processes in `TaskStore`
  """
  @spec start_link(list(any())) :: {atom(), pid()}
  def start_link(opts) do 
    Supervisor.start_link(__MODULE__, :ok, opts)
  end 

  @doc """
  This function runs the work needed to initialize our supervisor when starting it
  """
  def init(:ok) do 
    children = [
      {DynamicSupervisor, name: TaskStore.TaskListSupervisor, strategy: :one_for_one},
      {TaskStore.Registry, name: TaskStore.Registry}, 
      {Task.Supervisor, name: TaskStore.RouterTasks}
    ]

    # set the strategy to `one_for_one` so whichever child that dies is the only one that is restarted
    Supervisor.init(children, strategy: :one_for_all)
  end 
end 
