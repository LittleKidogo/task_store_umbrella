defmodule TaskStoreServerTest do
  @moduledoc """
  This module holds integration tests that exercise the full stack of our application to ensure commands 
  are handled correctly from the TCP server all the way to the TaskList and back
  """
  use ExUnit.Case
  
  setup do 
    Application.stop(:task_store)
    :ok = Application.start(:task_store)
  end 
  
  setup do 
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 9090, opts)
    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN shopping\r\n") ==
          "UNKOWN COMMAND\r\n"

    assert send_and_recv(socket, "GET gardening cut-grass\r\n") ==
           "NOT FOUND\r\n"
    
    assert send_and_recv(socket, "CREATE gardening\r\n") ==
           "OK\r\n"

    assert send_and_recv(socket, "PUT gardening cut-grass 1pm-2pm\r\n") ==
           "OK\r\n"
    
    # GET returns two lines 
    assert send_and_recv(socket, "GET gardening cut-grass\r\n") == "1pm-2pm\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE gardening cut-grass\r\n") ==
           "OK\r\n"

    # GET returns two lines
    assert send_and_recv(socket, "GET gardening cut-grass\r\n") == "\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"
  end 

  defp send_and_recv(socket, command) do 
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end 
end
