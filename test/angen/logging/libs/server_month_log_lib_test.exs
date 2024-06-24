defmodule Angen.ServerMonthLogLibTest do
  @moduledoc false
  alias Angen.Logging.ServerMonthLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

  defp valid_attrs do
    %{
      date: Timex.today(),
      year: 1,
      month: 1,
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Timex.today() |> Timex.shift(months: 1),
      year: 2,
      month: 2,
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      date: nil,
      data: nil
    }
  end

  describe "server_month_log" do
    alias Angen.Logging.ServerMonthLog

    test "server_month_log_query/0 returns a query" do
      q = Logging.server_month_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_month_log/0 returns server_month_log" do
      # No server_month_log yet
      assert Logging.list_server_month_logs([]) == []

      # Add a server_month_log
      LoggingFixtures.server_month_log_fixture()
      assert Logging.list_server_month_logs([]) != []
    end

    test "get_server_month_log!/1 and get_server_month_log/1 returns the server_month_log with given id" do
      server_month_log = LoggingFixtures.server_month_log_fixture()
      assert Logging.get_server_month_log!(server_month_log.date) == server_month_log
      assert Logging.get_server_month_log(server_month_log.date) == server_month_log
    end

    test "create_server_month_log/1 with valid data creates a server_month_log" do
      assert {:ok, %ServerMonthLog{} = server_month_log} =
               Logging.create_server_month_log(valid_attrs())

      assert server_month_log.data == %{"key" => 1}
    end

    test "create_server_month_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_server_month_log(invalid_attrs())
    end

    test "update_server_month_log/2 with valid data updates the server_month_log" do
      server_month_log = LoggingFixtures.server_month_log_fixture()

      assert {:ok, %ServerMonthLog{} = server_month_log} =
               Logging.update_server_month_log(server_month_log, update_attrs())

      assert server_month_log.data == %{"other-key" => 2}
    end

    test "update_server_month_log/2 with invalid data returns error changeset" do
      server_month_log = LoggingFixtures.server_month_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_server_month_log(server_month_log, invalid_attrs())

      assert server_month_log == Logging.get_server_month_log!(server_month_log.date)
    end

    test "delete_server_month_log/1 deletes the server_month_log" do
      server_month_log = LoggingFixtures.server_month_log_fixture()
      assert {:ok, %ServerMonthLog{}} = Logging.delete_server_month_log(server_month_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_server_month_log!(server_month_log.date)
      end

      assert Logging.get_server_month_log(server_month_log.date) == nil
    end

    test "change_server_month_log/1 returns a server_month_log changeset" do
      server_month_log = LoggingFixtures.server_month_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_server_month_log(server_month_log)
    end
  end
end
