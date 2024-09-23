defmodule Angen.ServerDayLogLibTest do
  @moduledoc false
  alias Angen.Logging.ServerDayLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

  defp valid_attrs do
    %{
      date: Angen.Helper.DateTimeHelper.today(),
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Angen.Helper.DateTimeHelper.today() |> Date.shift(day: 1),
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      date: nil,
      data: nil
    }
  end

  describe "server_day_log" do
    alias Angen.Logging.ServerDayLog

    test "server_day_log_query/0 returns a query" do
      q = Logging.server_day_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_day_log/0 returns server_day_log" do
      # No server_day_log yet
      assert Logging.list_server_day_logs([]) == []

      # Add a server_day_log
      LoggingFixtures.server_day_log_fixture()
      assert Logging.list_server_day_logs([]) != []
    end

    test "get_server_day_log!/1 and get_server_day_log/1 returns the server_day_log with given id" do
      server_day_log = LoggingFixtures.server_day_log_fixture()
      assert Logging.get_server_day_log!(server_day_log.date) == server_day_log
      assert Logging.get_server_day_log(server_day_log.date) == server_day_log
    end

    test "create_server_day_log/1 with valid data creates a server_day_log" do
      assert {:ok, %ServerDayLog{} = server_day_log} =
               Logging.create_server_day_log(valid_attrs())

      assert server_day_log.data == %{"key" => 1}
    end

    test "create_server_day_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_server_day_log(invalid_attrs())
    end

    test "update_server_day_log/2 with valid data updates the server_day_log" do
      server_day_log = LoggingFixtures.server_day_log_fixture()

      assert {:ok, %ServerDayLog{} = server_day_log} =
               Logging.update_server_day_log(server_day_log, update_attrs())

      assert server_day_log.data == %{"other-key" => 2}
    end

    test "update_server_day_log/2 with invalid data returns error changeset" do
      server_day_log = LoggingFixtures.server_day_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_server_day_log(server_day_log, invalid_attrs())

      assert server_day_log == Logging.get_server_day_log!(server_day_log.date)
    end

    test "delete_server_day_log/1 deletes the server_day_log" do
      server_day_log = LoggingFixtures.server_day_log_fixture()
      assert {:ok, %ServerDayLog{}} = Logging.delete_server_day_log(server_day_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_server_day_log!(server_day_log.date)
      end

      assert Logging.get_server_day_log(server_day_log.date) == nil
    end

    test "change_server_day_log/1 returns a server_day_log changeset" do
      server_day_log = LoggingFixtures.server_day_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_server_day_log(server_day_log)
    end
  end
end
