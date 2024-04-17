defmodule Angen.ServerYearLogLibTest do
  @moduledoc false
  alias Angen.Logging.ServerYearLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.LoggingFixtures

  defp valid_attrs do
    %{
      date: Timex.today(),
      year: 1,
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Timex.today() |> Timex.shift(years: 1),
      year: 2,
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      date: nil,
      data: nil
    }
  end

  describe "server_year_log" do
    alias Angen.Logging.ServerYearLog

    test "server_year_log_query/0 returns a query" do
      q = Logging.server_year_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_year_log/0 returns server_year_log" do
      # No server_year_log yet
      assert Logging.list_server_year_logs([]) == []

      # Add a server_year_log
      LoggingFixtures.server_year_log_fixture()
      assert Logging.list_server_year_logs([]) != []
    end

    test "get_server_year_log!/1 and get_server_year_log/1 returns the server_year_log with given id" do
      server_year_log = LoggingFixtures.server_year_log_fixture()
      assert Logging.get_server_year_log!(server_year_log.date) == server_year_log
      assert Logging.get_server_year_log(server_year_log.date) == server_year_log
    end

    test "create_server_year_log/1 with valid data creates a server_year_log" do
      assert {:ok, %ServerYearLog{} = server_year_log} =
               Logging.create_server_year_log(valid_attrs())

      assert server_year_log.data == %{"key" => 1}
    end

    test "create_server_year_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_server_year_log(invalid_attrs())
    end

    test "update_server_year_log/2 with valid data updates the server_year_log" do
      server_year_log = LoggingFixtures.server_year_log_fixture()

      assert {:ok, %ServerYearLog{} = server_year_log} =
               Logging.update_server_year_log(server_year_log, update_attrs())

      assert server_year_log.data == %{"other-key" => 2}
    end

    test "update_server_year_log/2 with invalid data returns error changeset" do
      server_year_log = LoggingFixtures.server_year_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_server_year_log(server_year_log, invalid_attrs())

      assert server_year_log == Logging.get_server_year_log!(server_year_log.date)
    end

    test "delete_server_year_log/1 deletes the server_year_log" do
      server_year_log = LoggingFixtures.server_year_log_fixture()
      assert {:ok, %ServerYearLog{}} = Logging.delete_server_year_log(server_year_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_server_year_log!(server_year_log.date)
      end

      assert Logging.get_server_year_log(server_year_log.date) == nil
    end

    test "change_server_year_log/1 returns a server_year_log changeset" do
      server_year_log = LoggingFixtures.server_year_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_server_year_log(server_year_log)
    end
  end
end
