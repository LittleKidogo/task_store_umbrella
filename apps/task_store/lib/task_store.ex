defmodule TaskStore do
  @moduledoc """
  This module holds the application callback for the `TaskStore` application
  """
  use Application 
  
  @doc """
  This function starts our application supervisor
  """
  @spec start(any(), any()) :: {:ok, pid()}
  def start(_type, _args) do
    TaskStore.Supervisor.start_link(name: TaskStore.Supervisor)
  end 
end
