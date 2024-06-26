defmodule Angen.Telemetry.TelemetryHelper do
  @moduledoc false
  require Logger

  def handle_event(event, measure, meta, opts) do
    # [info] [:teiserver, :client, :new_connection], %{}, %{user_id: "f41c10c2-e8bf-4422-9584-4b03d49aa383"}, []
    Logger.info("#{inspect(event)}, #{inspect(measure)}, #{inspect(meta)}, #{inspect(opts)}")
  end
end
