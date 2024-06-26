defmodule Angen.PersistServerMinuteTaskTest do
  @moduledoc false
  alias Angen.{Logging, Repo}
  alias Angen.Logging.PersistServerMinuteTask
  # alias Angen.Fixtures.LoggingFixtures

  # This test relies on some live connections to test fully, as such it has to be sync
  # while the others are purely DB and thus can be async
  # use Angen.DataCase, async: false
  use Angen.ProtoCase, async: false

  test "test persisting" do
    %{socket: _s1} = auth_connection()
    %{socket: _s2} = auth_connection(bot?: true)
    %{socket: _h2} = lobby_host_connection()

    node = Teiserver.get_node_name()

    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_minute_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    now = Timex.now() |> Timex.set(microsecond: 0, second: 0)
    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: now)

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
    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: now)
    log = Logging.get_server_minute_log(now, node)

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "client")
    assert Map.has_key?(log.data, "lobby")

    # Now use the trigger and see what happens
    Angen.Logging.TriggerPersistServerMinuteTask.perform(:ok)
  end
end
