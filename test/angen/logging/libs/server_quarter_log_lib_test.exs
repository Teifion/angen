defmodule Angen.ServerQuarterLogLibTest do
  @moduledoc false
  alias Angen.Logging.ServerQuarterLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

  defp valid_attrs do
    %{
      date: Timex.today(),
      year: 1,
      quarter: 1,
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Timex.today() |> Timex.shift(months: 3),
      year: 2,
      quarter: 2,
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      date: nil,
      year: nil,
      quarter: nil,
      data: nil
    }
  end

  describe "server_quarter_log" do
    alias Angen.Logging.ServerQuarterLog

    test "server_quarter_log_query/0 returns a query" do
      q = Logging.server_quarter_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_quarter_log/0 returns server_quarter_log" do
      # No server_quarter_log yet
      assert Logging.list_server_quarter_logs([]) == []

      # Add a server_quarter_log
      LoggingFixtures.server_quarter_log_fixture()
      assert Logging.list_server_quarter_logs([]) != []
    end

    test "get_server_quarter_log!/1 and get_server_quarter_log/1 returns the server_quarter_log with given id" do
      server_quarter_log = LoggingFixtures.server_quarter_log_fixture()
      assert Logging.get_server_quarter_log!(server_quarter_log.date) == server_quarter_log
      assert Logging.get_server_quarter_log(server_quarter_log.date) == server_quarter_log
    end

    test "create_server_quarter_log/1 with valid data creates a server_quarter_log" do
      assert {:ok, %ServerQuarterLog{} = server_quarter_log} =
               Logging.create_server_quarter_log(valid_attrs())

      assert server_quarter_log.data == %{"key" => 1}
    end

    test "create_server_quarter_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_server_quarter_log(invalid_attrs())
    end

    test "update_server_quarter_log/2 with valid data updates the server_quarter_log" do
      server_quarter_log = LoggingFixtures.server_quarter_log_fixture()

      assert {:ok, %ServerQuarterLog{} = server_quarter_log} =
               Logging.update_server_quarter_log(server_quarter_log, update_attrs())

      assert server_quarter_log.data == %{"other-key" => 2}
    end

    test "update_server_quarter_log/2 with invalid data returns error changeset" do
      server_quarter_log = LoggingFixtures.server_quarter_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_server_quarter_log(server_quarter_log, invalid_attrs())

      assert server_quarter_log == Logging.get_server_quarter_log!(server_quarter_log.date)
    end

    test "delete_server_quarter_log/1 deletes the server_quarter_log" do
      server_quarter_log = LoggingFixtures.server_quarter_log_fixture()
      assert {:ok, %ServerQuarterLog{}} = Logging.delete_server_quarter_log(server_quarter_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_server_quarter_log!(server_quarter_log.date)
      end

      assert Logging.get_server_quarter_log(server_quarter_log.date) == nil
    end

    test "change_server_quarter_log/1 returns a server_quarter_log changeset" do
      server_quarter_log = LoggingFixtures.server_quarter_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_server_quarter_log(server_quarter_log)
    end
  end
end
