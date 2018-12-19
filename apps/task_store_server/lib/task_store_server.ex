defmodule TaskStoreServer do
  @moduledoc """
  A TCP server that accepts and processes requests to the `TaskStore` application
  """
  require Logger

  @doc """
  This function accepts a connection to the part that is being listened to and 
  proceeds to enage the loop acceptor to keep taking in subsequest requests
  """
  @spec accept(integer()) :: any()
  def accept(port) do 
    # use :binary - recieve binaries rather than lists 
    # packet: :line - reads the data line by line 
    # active: false  - blocks until data is available 
    # reuseaddr: true - allows us to reuse the listener address if that process crashes
    
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end 

  @spec loop_acceptor(any()) :: any() 
  defp loop_acceptor(socket) do 
    {ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(TaskStoreServer.TaskSupervisor, fn -> serve(client) end)
    :ok  = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end 

  @spec serve(any()) :: any()
  defp serve(socket) do
    msg =
      with {:ok, data} <- read_line(socket), 
          {:ok, command} <- TaskStoreServer.Command.parse(data), 
          do: TaskStoreServer.Command.run(command)
      
    write_line(socket, msg)
    serve(socket)
  end 

  @spec read_line(any()) :: binary()
  defp read_line(socket) do 
    :gen_tcp.recv(socket, 0)
  end 

  @spec write_line(any(), tuple()) :: any()
  defp write_line(socket, {:ok, text}) do 
    :gen_tcp.send(socket, text)
  end 

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write_line(socket, {:error, :unknown_command}) do
     :gen_tcp.send(socket, "UNKOWN COMMAND\r\n")
  end 

  defp write_line(_socket, {:error, :closed}) do 
    exit(:shutdown)
  end 

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end 
end
