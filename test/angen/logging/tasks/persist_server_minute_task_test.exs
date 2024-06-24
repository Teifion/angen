defmodule Angen.PersistServerMinuteTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.PersistServerMinuteTask
  # alias Angen.Fixtures.LoggingFixtures
  use Angen.DataCase, async: true

  test "test persisting" do
    node = Teiserver.get_node_name()

    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_minute_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    now = Timex.now() |> Timex.set(microsecond: 0, second: 0)
    assert :ok == PersistServerMinuteTask.perform(now: now)

    # Now ensure it ran
    log = Logging.get_server_minute_log(now, node)

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "client")
    assert Map.has_key?(log.data, "lobby")

    # Now we set that to a minute ago and run it again
    last_minute = Timex.shift(now, minutes: -1)
    Logging.update_server_minute_log(log, %{timestamp: last_minute})

    log = Logging.get_server_minute_log(now, node)
    assert log == nil

    # Run again
    assert :ok == PersistServerMinuteTask.perform(now: now)
    log = Logging.get_server_minute_log(now, node)

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "client")
    assert Map.has_key?(log.data, "lobby")
  end
end
