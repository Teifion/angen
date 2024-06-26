defmodule Angen.PersistServerWeekTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.PersistServerWeekTask
  use Angen.DataCase, async: true

  test "test basic" do
    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_week_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    query = "DELETE FROM logging_server_day_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    Angen.FakeData.FakeLogging.make_server_days(%{
      days: 365 * 4,
      detail_days: 365 * 4,
      max_users: 20
    })

    # Now run it
    {:ok, first_returned_log} = PersistServerWeekTask.do_perform()
    log = Logging.get_server_week_log(first_returned_log.date)
    assert log.data == Jason.decode!(Jason.encode!(first_returned_log.data))

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "stats")
    assert Map.has_key?(log.data, "peak_user_counts")

    assert Enum.count(Logging.list_server_week_logs([])) == 1

    # Now run it a few more times
    0..5
    |> Enum.each(fn _ -> PersistServerWeekTask.do_perform() end)

    # Now get the logs
    logs = Logging.list_server_week_logs(order_by: "Oldest first")
    [log1, log2 | _] = logs

    refute log1.data == log2.data
    assert log1.week == log2.week - 1

    # The first one we made and then the 0-5 generates 6 more
    assert Enum.count(Logging.list_server_week_logs([])) == 7

    weeks = for l <- logs, do: l.week
    assert Enum.at(weeks, 0) == Enum.at(weeks, 6) - 6

    # Finally, perform the task instead of do_perform
    assert :ok == PersistServerWeekTask.perform(:ok)
  end
end
