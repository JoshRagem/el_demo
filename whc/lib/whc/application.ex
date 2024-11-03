defmodule Whc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WhcWeb.Telemetry,
      Whc.Repo,
      {DNSCluster, query: Application.get_env(:whc, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Whc.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Whc.Finch},
      # Start a worker by calling: Whc.Worker.start_link(arg)
      # {Whc.Worker, arg},
      # Start to serve requests, typically the last entry
      WhcWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Whc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
