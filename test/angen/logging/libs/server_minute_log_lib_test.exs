defmodule Angen.ServerMinuteLogLibTest do
  @moduledoc false
  alias Angen.Logging.ServerMinuteLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.LoggingFixtures

  defp valid_attrs do
    %{
      timestamp: Timex.now(),
      node: "test-node",
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      timestamp: Timex.now() |> Timex.shift(minutes: 1),
      node: "updated-test-node",
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      timestamp: nil,
      node: nil,
      data: nil
    }
  end

  describe "server_minute_log" do
    alias Angen.Logging.ServerMinuteLog

    test "server_minute_log_query/0 returns a query" do
      q = Logging.server_minute_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_minute_log/0 returns server_minute_log" do
      # No server_minute_log yet
      assert Logging.list_server_minute_logs([]) == []

      # Add a server_minute_log
      LoggingFixtures.server_minute_log_fixture()
      assert Logging.list_server_minute_logs([]) != []
    end

    test "get_server_minute_log!/1 and get_server_minute_log/1 returns the server_minute_log with given id" do
      server_minute_log = LoggingFixtures.server_minute_log_fixture()
      assert Logging.get_server_minute_log!(server_minute_log.timestamp) == server_minute_log
      assert Logging.get_server_minute_log(server_minute_log.timestamp) == server_minute_log
    end

    test "create_server_minute_log/1 with valid data creates a server_minute_log" do
      assert {:ok, %ServerMinuteLog{} = server_minute_log} =
               Logging.create_server_minute_log(valid_attrs())

      assert server_minute_log.data == %{"key" => 1}
    end

    test "create_server_minute_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_server_minute_log(invalid_attrs())
    end

    test "update_server_minute_log/2 with valid data updates the server_minute_log" do
      server_minute_log = LoggingFixtures.server_minute_log_fixture()

      assert {:ok, %ServerMinuteLog{} = server_minute_log} =
               Logging.update_server_minute_log(server_minute_log, update_attrs())

      assert server_minute_log.data == %{"other-key" => 2}
    end

    test "update_server_minute_log/2 with invalid data returns error changeset" do
      server_minute_log = LoggingFixtures.server_minute_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_server_minute_log(server_minute_log, invalid_attrs())

      assert server_minute_log == Logging.get_server_minute_log!(server_minute_log.timestamp)
    end

    test "delete_server_minute_log/1 deletes the server_minute_log" do
      server_minute_log = LoggingFixtures.server_minute_log_fixture()
      assert {:ok, %ServerMinuteLog{}} = Logging.delete_server_minute_log(server_minute_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_server_minute_log!(server_minute_log.timestamp)
      end

      assert Logging.get_server_minute_log(server_minute_log.timestamp) == nil
    end

    test "change_server_minute_log/1 returns a server_minute_log changeset" do
      server_minute_log = LoggingFixtures.server_minute_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_server_minute_log(server_minute_log)
    end
  end
end
