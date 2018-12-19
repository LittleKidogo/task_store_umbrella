defmodule TaskStoreServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    port = String.to_integer(System.get_env("PORT") || "9090")
    children = [
      {Task.Supervisor, name: TaskStoreServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> TaskStoreServer.accept(port) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TaskStoreServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
