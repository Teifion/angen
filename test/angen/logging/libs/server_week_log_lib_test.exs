defmodule Angen.ServerWeekLogLibTest do
  @moduledoc false
  alias Angen.Logging.ServerWeekLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

  defp valid_attrs do
    %{
      date: Timex.today(),
      year: 1,
      week: 1,
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Timex.today() |> Timex.shift(weeks: 1),
      year: 2,
      week: 2,
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      date: nil,
      data: nil
    }
  end

  describe "server_week_log" do
    alias Angen.Logging.ServerWeekLog

    test "server_week_log_query/0 returns a query" do
      q = Logging.server_week_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_week_log/0 returns server_week_log" do
      # No server_week_log yet
      assert Logging.list_server_week_logs([]) == []

      # Add a server_week_log
      LoggingFixtures.server_week_log_fixture()
      assert Logging.list_server_week_logs([]) != []
    end

    test "get_server_week_log!/1 and get_server_week_log/1 returns the server_week_log with given id" do
      server_week_log = LoggingFixtures.server_week_log_fixture()
      assert Logging.get_server_week_log!(server_week_log.date) == server_week_log
      assert Logging.get_server_week_log(server_week_log.date) == server_week_log
    end

    test "create_server_week_log/1 with valid data creates a server_week_log" do
      assert {:ok, %ServerWeekLog{} = server_week_log} =
               Logging.create_server_week_log(valid_attrs())

      assert server_week_log.data == %{"key" => 1}
    end

    test "create_server_week_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_server_week_log(invalid_attrs())
    end

    test "update_server_week_log/2 with valid data updates the server_week_log" do
      server_week_log = LoggingFixtures.server_week_log_fixture()

      assert {:ok, %ServerWeekLog{} = server_week_log} =
               Logging.update_server_week_log(server_week_log, update_attrs())

      assert server_week_log.data == %{"other-key" => 2}
    end

    test "update_server_week_log/2 with invalid data returns error changeset" do
      server_week_log = LoggingFixtures.server_week_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_server_week_log(server_week_log, invalid_attrs())

      assert server_week_log == Logging.get_server_week_log!(server_week_log.date)
    end

    test "delete_server_week_log/1 deletes the server_week_log" do
      server_week_log = LoggingFixtures.server_week_log_fixture()
      assert {:ok, %ServerWeekLog{}} = Logging.delete_server_week_log(server_week_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_server_week_log!(server_week_log.date)
      end

      assert Logging.get_server_week_log(server_week_log.date) == nil
    end

    test "change_server_week_log/1 returns a server_week_log changeset" do
      server_week_log = LoggingFixtures.server_week_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_server_week_log(server_week_log)
    end
  end
end
