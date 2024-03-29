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
      AngenWeb.Telemetry,
      Angen.Repo,
      {Phoenix.PubSub, name: Angen.PubSub},
      {Finch, name: Angen.Finch},
      AngenWeb.Endpoint,

      # Integration mode
      Angen.DevSupport.IntegrationSupervisor,

      # Caches
      %{
        id: :protocol_schemas,
        start:
          {Cachex, :start_link,
           [
             :protocol_schemas,
             []
           ]}
      },
      %{
        id: :protocol_command_dispatches,
        start:
          {Cachex, :start_link,
           [
             :protocol_command_dispatches,
             []
           ]}
      },

      # %{
      #   id: :protocol_roots,
      #   start: {Cachex, :start_link, [
      #     :protocol_roots,
      #     []
      #   ]}
      # },

      # {Oban, oban_config()},
      {ThousandIsland,
       port: Application.get_env(:angen, :tls_port),
       handler_module: Angen.TextProtocol.TextHandlerServer,
       transport_module: ThousandIsland.Transports.SSL,
       transport_options: [
         keyfile: Application.get_env(:angen, :certs)[:keyfile],
         certfile: Application.get_env(:angen, :certs)[:certfile]
         # certfile: Application.get_env(:angen, :certs)[:cacertfile]
       ]}
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
    Angen.DevSupport.IntegrationSupervisor.start_integration_supervisor_children()
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AngenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
