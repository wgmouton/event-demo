defmodule EventDemo.Application do
  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("Application starting ...")

    children = [
      {Plug.Cowboy, scheme: :http, plug: EventDemo.HttpServer, options: [port: 4001]}
    ]

    opts = [
      strategy: :one_for_one,
      restart: :permanent,
      name: EventDemo.Supervisor
    ]

    res = Supervisor.start_link(children, opts)

    Logger.info("Application started ...")

    res
  end

  def version() do
    {:version, "0.0.1"}
  end
end
