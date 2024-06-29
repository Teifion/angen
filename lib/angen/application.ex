defmodule Angen.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Ecto.Migrator,
       repos: Application.fetch_env!(:angen, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true"},
      Angen.TelemetrySupervisor,
      Angen.Repo,
      {Phoenix.PubSub, name: Angen.PubSub},
      {Finch, name: Angen.Finch},
      AngenWeb.Endpoint,

      # Integration mode
      Angen.DevSupport.IntegrationSupervisor,

      # Caches
      Teiserver.Caches.MetadataCache,
      Teiserver.Caches.UserLoginCache,
      Teiserver.Caches.ProtocolCache,
      Teiserver.Caches.TelemetryEventCache,

      # Client connections
      {Horde.Registry, [keys: :unique, members: :auto, name: Angen.ConnectionRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Angen.LocalConnectionRegistry]},
      {ThousandIsland,
       port: Application.get_env(:angen, :tls_port),
       handler_module: Angen.TextProtocol.TextHandlerServer,
       transport_module: ThousandIsland.Transports.SSL,
       transport_options: [
         keyfile: Application.get_env(:angen, :certs)[:keyfile],
         certfile: Application.get_env(:angen, :certs)[:certfile]
         # certfile: Application.get_env(:angen, :certs)[:cacertfile]
       ]},
      {Angen.TaskServer, name: Angen.TaskServer},
      {Oban, oban_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Angen.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    # We use this log line to know the supervisor tree started without issues
    # if you don't see this it means one of the processes above has had an issue
    # starting up
    Logger.info("Angen.Supervisor start result: #{Kernel.inspect(start_result)}")

    startup()

    Logger.info("Angen startup completed")

    start_result
  end

  defp startup() do
    Angen.Settings.ServerSettings.create_server_settings()
    Angen.DevSupport.IntegrationSupervisor.start_integration_supervisor_children()

    # Collector server
    :telemetry.attach_many(
      "teiserver-collector",
      Teiserver.Telemetry.event_list(),
      &Angen.Telemetry.TeiserverCollectorServer.handle_event/4,
      []
    )

    :telemetry.attach_many(
      "angen-collector",
      Angen.Telemetry.event_list(),
      &Angen.Telemetry.AngenCollectorServer.handle_event/4,
      []
    )

    # For when we want to track Oban events
    # oban_events = [
    #   [:oban, :job, :start],
    #   [:oban, :job, :stop],
    #   [:oban, :job, :exception],
    #   [:oban, :circuit, :trip]
    # ]
    # :telemetry.attach_many("oban-logger", events, &Teiserver.Helper.ObanLogger.handle_event/4, [])

    Cachex.put(:angen_metadata, :startup_complete, true)

    # Straight to logs
    # :telemetry.attach_many("teiserver-logger", teiserver_events, &Angen.Telemetry.TelemetryHelper.handle_event/4, [])
  end

  defp oban_config do
    Application.get_env(:angen, Oban)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AngenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
