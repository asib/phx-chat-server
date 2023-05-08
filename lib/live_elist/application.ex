defmodule LiveElist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveElistWeb.Telemetry,
      # Start the Ecto repository
      LiveElist.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveElist.PubSub},
      # Start Finch
      {Finch, name: LiveElist.Finch},
      # Start the Endpoint (http/https)
      LiveElistWeb.Endpoint,
      # Start a worker by calling: LiveElist.Worker.start_link(arg)
      # {LiveElist.Worker, arg}
      LiveElist.ChatServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveElist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveElistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
