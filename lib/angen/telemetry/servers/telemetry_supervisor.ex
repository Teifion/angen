defmodule Angen.TelemetrySupervisor do
  @moduledoc false
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: teiserver_metrics()}

      {Angen.Telemetry.TeiserverCollectorServer, name: Angen.Telemetry.TeiserverCollectorServer},
      {Angen.Telemetry.AngenCollectorServer, name: Angen.Telemetry.AngenCollectorServer}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec metrics() :: list()
  def metrics do
    phoenix_metrics() ++ repo_metrics() ++ vm_metrics() ++ teiserver_metrics() ++ angen_metrics()
  end

  defp phoenix_metrics() do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.start.system_time",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.start.system_time",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.exception.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.socket_connected.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.channel_join.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.channel_handled_in.duration",
        tags: [:event],
        unit: {:native, :millisecond}
      )
    ]
  end

  defp repo_metrics() do
    [
      summary("angen.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      summary("angen.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      summary("angen.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      summary("angen.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      summary("angen.repo.query.idle_time",
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      )
    ]
  end

  defp vm_metrics() do
    [
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp teiserver_metrics() do
    [
      counter("teiserver.user.failed_login.reason"),

      counter("teiserver.client.event.type", description: "ClientServer events"),
      counter("teiserver.client.disconnect.reason"),

      counter("teiserver.lobby.event.type"),

      summary("teiserver.logging.add_audit_log.action")
    ]
  end

  defp angen_metrics() do
    [
      distribution("angen.protocol.response.stop.duration", buckets: [500, 1000, 3000, 7500, 15000], unit: {:native, :microsecond}, description: "Resp dist"),
      summary("angen.protocol.response.stop.duration", description: "Resp summary"),
      counter("angen.protocol.response.stop.duration", description: "Resp span"),
      counter("angen.proto.response.name", description: "Resp emit")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {AngenWeb, :count_users, []}
    ]
  end
end
