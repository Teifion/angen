defmodule Angen.PersistServerDayTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.{PersistServerMinuteTask, PersistServerDayTask}
  use Angen.DataCase, async: true
  alias Angen.Helper.DateTimeHelper

  test "test basic" do
    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_day_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    now = DateTime.utc_now() |> DateTime.shift(day: -1) |> DateTime.truncate(:second)
    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: DateTime.shift(now, minute: -1))
    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: DateTime.shift(now, minute: -2))
    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: DateTime.shift(now, minute: -3))

    # Set all of them to "all"
    query = "UPDATE logging_server_minute_logs SET node = 'all';"
    Ecto.Adapters.SQL.query(Repo, query, [])

    # Now run it
    assert :ok == PersistServerDayTask.perform(:ok)
    log = Logging.get_server_day_log(DateTimeHelper.today() |> Date.shift(day: -1))

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "stats")
    assert Map.has_key?(log.data, "peak_user_counts")

    # Run again so we know it won't error if one already exists
    assert :ok == PersistServerDayTask.perform(:ok)
  end
end
