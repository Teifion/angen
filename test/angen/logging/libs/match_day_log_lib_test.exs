defmodule Angen.MatchDayLogLibTest do
  @moduledoc false
  alias Angen.Logging.MatchDayLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.LoggingFixtures

  defp valid_attrs do
    %{
      date: Timex.today(),
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Timex.today() |> Timex.shift(days: 1),
      data: %{"other-key" => 2}
    }
  end

  defp invalid_attrs do
    %{
      date: nil,
      data: nil
    }
  end

  describe "match_day_log" do
    alias Angen.Logging.MatchDayLog

    test "match_day_log_query/0 returns a query" do
      q = Logging.match_day_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_day_log/0 returns match_day_log" do
      # No match_day_log yet
      assert Logging.list_match_day_logs([]) == []

      # Add a match_day_log
      LoggingFixtures.match_day_log_fixture()
      assert Logging.list_match_day_logs([]) != []
    end

    test "get_match_day_log!/1 and get_match_day_log/1 returns the match_day_log with given id" do
      match_day_log = LoggingFixtures.match_day_log_fixture()
      assert Logging.get_match_day_log!(match_day_log.date) == match_day_log
      assert Logging.get_match_day_log(match_day_log.date) == match_day_log
    end

    test "create_match_day_log/1 with valid data creates a match_day_log" do
      assert {:ok, %MatchDayLog{} = match_day_log} =
               Logging.create_match_day_log(valid_attrs())

      assert match_day_log.data == %{"key" => 1}
    end

    test "create_match_day_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_match_day_log(invalid_attrs())
    end

    test "update_match_day_log/2 with valid data updates the match_day_log" do
      match_day_log = LoggingFixtures.match_day_log_fixture()

      assert {:ok, %MatchDayLog{} = match_day_log} =
               Logging.update_match_day_log(match_day_log, update_attrs())

      assert match_day_log.data == %{"other-key" => 2}
    end

    test "update_match_day_log/2 with invalid data returns error changeset" do
      match_day_log = LoggingFixtures.match_day_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_match_day_log(match_day_log, invalid_attrs())

      assert match_day_log == Logging.get_match_day_log!(match_day_log.date)
    end

    test "delete_match_day_log/1 deletes the match_day_log" do
      match_day_log = LoggingFixtures.match_day_log_fixture()
      assert {:ok, %MatchDayLog{}} = Logging.delete_match_day_log(match_day_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_match_day_log!(match_day_log.date)
      end

      assert Logging.get_match_day_log(match_day_log.date) == nil
    end

    test "change_match_day_log/1 returns a match_day_log changeset" do
      match_day_log = LoggingFixtures.match_day_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_match_day_log(match_day_log)
    end
  end
end
