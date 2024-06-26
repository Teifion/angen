defmodule Angen.PersistServerYearTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.PersistServerYearTask
  use Angen.DataCase, async: true

  test "test basic" do
    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_year_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    query = "DELETE FROM logging_server_day_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    Angen.FakeData.FakeLogging.make_server_days(%{
      days: 365 * 4,
      detail_days: 365 * 4,
      max_users: 20
    })

    # Now run it
    {:ok, first_returned_log} = PersistServerYearTask.do_perform()
    assert first_returned_log.date.month == 1
    assert first_returned_log.date.day == 1
    log = Logging.get_server_year_log(first_returned_log.date)
    assert log.data == Jason.decode!(Jason.encode!(first_returned_log.data))

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "stats")
    assert Map.has_key?(log.data, "peak_user_counts")

    assert Enum.count(Logging.list_server_year_logs([])) == 1

    # Now run it a few more times
    0..5
    |> Enum.each(fn _ -> PersistServerYearTask.do_perform() end)

    # Now get the logs
    logs = Logging.list_server_year_logs(order_by: "Oldest first")
    [log1, log2 | _] = logs

    refute log1.data == log2.data

    assert log1.date.year == log2.date.year - 1

    assert Enum.count(Logging.list_server_year_logs([])) == 4

    # Finally, perform the task instead of do_perform
    assert :ok == PersistServerYearTask.perform(:ok)
  end
end
