defmodule Angen.PersistServerDayTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.{PersistServerMinuteTask, PersistServerDayTask}
  use Angen.DataCase, async: true

  test "test basic" do
    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_day_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    now = Timex.now() |> Timex.shift(days: -1) |> Timex.set(microsecond: 0, second: 0)
    assert :ok == PersistServerMinuteTask.perform(now: Timex.shift(now, minutes: -1))
    assert :ok == PersistServerMinuteTask.perform(now: Timex.shift(now, minutes: -2))
    assert :ok == PersistServerMinuteTask.perform(now: Timex.shift(now, minutes: -3))

    # Set all of them to "all"
    query = "UPDATE logging_server_minute_logs SET node = 'all';"
    Ecto.Adapters.SQL.query(Repo, query, [])

    # Now run it
    assert :ok == PersistServerDayTask.perform(:ok)
    log = Logging.get_server_day_log(Timex.today() |> Timex.shift(days: -1))

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "stats")
    assert Map.has_key?(log.data, "peak_user_counts")
  end
end
