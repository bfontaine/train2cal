defmodule Train2cal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Train2calWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Train2cal.PubSub},
      # Start the Endpoint (http/https)
      Train2calWeb.Endpoint
      # Start a worker by calling: Train2cal.Worker.start_link(arg)
      # {Train2cal.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Train2cal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Train2calWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
