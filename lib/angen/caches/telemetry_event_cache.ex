defmodule Angen.Caches.TelemetryEventCache do
  @moduledoc """
  Caches for telemetry event types.
  """

  use Supervisor
  import Teiserver.Helpers.CacheHelper, only: [add_cache: 2]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:telemetry_event_types_cache, ttl: :timer.minutes(15))
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
