defmodule Angen.CombineServerMinuteTaskTest do
  @moduledoc false
  alias Angen.Logging
  alias Angen.Logging.{PersistServerMinuteTask, CombineServerMinuteTask}
  # alias Angen.Fixtures.LoggingFixtures
  use Angen.DataCase, async: true

  test "test persisting" do
    node = Teiserver.get_node_name()

    # First, remove all prior logs
    query = "DELETE FROM logging_server_minute_logs"
    Ecto.Adapters.SQL.query(Repo, query, [])

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    # Create our logs
    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: now)
    log = Logging.get_server_minute_log(now, node)

    Logging.update_server_minute_log(log, %{
      node: "node1",
      data: put_in(log.data, ["lobby", "total"], 3)
    })

    {:ok, _returned_log} = PersistServerMinuteTask.perform(now: now)
    log = Logging.get_server_minute_log(now, node)

    Logging.update_server_minute_log(log, %{
      node: "node2",
      data: put_in(log.data, ["lobby", "total"], 3)
    })

    log = Logging.get_server_minute_log(now, node)
    assert log == nil

    log = Logging.get_server_minute_log(now, "all")
    assert log == nil

    # Now combine them
    assert :ok == CombineServerMinuteTask.perform(now: now)

    log = Logging.get_server_minute_log(now, "all")
    assert log.data["totals"]["nodes"] == 2
    assert log.data["lobby"]["total"] == 6
  end
end
