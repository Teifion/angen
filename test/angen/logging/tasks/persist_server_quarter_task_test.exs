defmodule Angen.PersistServerQuarterTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.PersistServerQuarterTask
  import Angen.Helpers.NumberHelper, only: [round: 2]
  use Angen.DataCase, async: true

  test "test basic" do
    # First, ensure it works with no prior logs
    query = "DELETE FROM logging_server_quarter_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    query = "DELETE FROM logging_server_day_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    Angen.FakeData.FakeLogging.make_server_days(%{
      days: 365 * 4,
      detail_days: 365 * 4,
      max_users: 20
    })

    # Now run it
    {:ok, first_returned_log} = PersistServerQuarterTask.do_perform()
    log = Logging.get_server_quarter_log(first_returned_log.date)
    assert log.data == Jason.decode!(Jason.encode!(first_returned_log.data))

    assert Map.has_key?(log.data, "telemetry_events")
    assert Map.has_key?(log.data, "stats")
    assert Map.has_key?(log.data, "peak_user_counts")

    assert Enum.count(Logging.list_server_quarter_logs([])) == 1

    # Now run it a few more times
    0..5
    |> Enum.each(fn _ -> PersistServerQuarterTask.do_perform() end)

    # Now get the logs
    logs = Logging.list_server_quarter_logs(order_by: "Oldest first")
    [log1, log2 | _] = logs

    refute log1.data == log2.data
    assert log1.quarter == log2.quarter - 1

    # The first one we made and then the 0-5 generates 6 more
    assert Enum.count(Logging.list_server_quarter_logs([])) == 7

    quarters = for l <- logs, do: l.year + l.quarter * 0.2
    assert round(Enum.at(quarters, 0), 1) == round(Enum.at(quarters, 6) - 1.4, 1)

    # Finally, perform the task instead of do_perform
    assert :ok == PersistServerQuarterTask.perform(:ok)
  end
end
