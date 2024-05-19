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
      {Angen.Telemetry.CollectorServer, name: Angen.Telemetry.CollectorServer},
      Angen.Repo,
      {Phoenix.PubSub, name: Angen.PubSub},
      {Finch, name: Angen.Finch},
      AngenWeb.Endpoint,

      # Integration mode
      Angen.DevSupport.IntegrationSupervisor,

      # Caches
      add_cache(:one_time_login_code, ttl: :timer.seconds(30)),
      add_cache(:user_token_identifier_cache, ttl: :timer.minutes(5)),
      add_cache(:angen_metadata),
      add_cache(:protocol_schemas),
      add_cache(:protocol_command_dispatches),

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

      {Oban, oban_config()},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Angen.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    Logger.info("Angen.Supervisor start result: #{Kernel.inspect(start_result)}")

    startup()

    Logger.info("Angen startup completed")

    start_result
  end

  defp startup() do
    Angen.Helpers.JsonSchemaHelper.load()
    Angen.TextProtocol.ExternalDispatch.cache_dispatches()
    Angen.Settings.ServerSettings.create_server_settings()
    Angen.DevSupport.IntegrationSupervisor.start_integration_supervisor_children()

    teiserver_events = Teiserver.Telemetry.event_list()
    angen_events = Angen.Telemetry.event_list()

    # Collector server
    :telemetry.attach_many("teiserver-collector", teiserver_events ++ angen_events, &Angen.Telemetry.CollectorServer.handle_event/4, [])

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

  @spec add_cache(atom) :: map()
  @spec add_cache(atom, list) :: map()
  defp add_cache(name, opts \\ []) when is_atom(name) do
    %{
      id: name,
      start:
        {Cachex, :start_link,
         [
           name,
           opts
         ]}
    }
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
