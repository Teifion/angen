defmodule Angen.MatchWeekLogLibTest do
  @moduledoc false
  alias Angen.Logging.MatchWeekLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.LoggingFixtures

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

  describe "match_week_log" do
    alias Angen.Logging.MatchWeekLog

    test "match_week_log_query/0 returns a query" do
      q = Logging.match_week_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_week_log/0 returns match_week_log" do
      # No match_week_log yet
      assert Logging.list_match_week_logs([]) == []

      # Add a match_week_log
      LoggingFixtures.match_week_log_fixture()
      assert Logging.list_match_week_logs([]) != []
    end

    test "get_match_week_log!/1 and get_match_week_log/1 returns the match_week_log with given id" do
      match_week_log = LoggingFixtures.match_week_log_fixture()
      assert Logging.get_match_week_log!(match_week_log.date) == match_week_log
      assert Logging.get_match_week_log(match_week_log.date) == match_week_log
    end

    test "create_match_week_log/1 with valid data creates a match_week_log" do
      assert {:ok, %MatchWeekLog{} = match_week_log} =
               Logging.create_match_week_log(valid_attrs())

      assert match_week_log.data == %{"key" => 1}
    end

    test "create_match_week_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_match_week_log(invalid_attrs())
    end

    test "update_match_week_log/2 with valid data updates the match_week_log" do
      match_week_log = LoggingFixtures.match_week_log_fixture()

      assert {:ok, %MatchWeekLog{} = match_week_log} =
               Logging.update_match_week_log(match_week_log, update_attrs())

      assert match_week_log.data == %{"other-key" => 2}
    end

    test "update_match_week_log/2 with invalid data returns error changeset" do
      match_week_log = LoggingFixtures.match_week_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_match_week_log(match_week_log, invalid_attrs())

      assert match_week_log == Logging.get_match_week_log!(match_week_log.date)
    end

    test "delete_match_week_log/1 deletes the match_week_log" do
      match_week_log = LoggingFixtures.match_week_log_fixture()
      assert {:ok, %MatchWeekLog{}} = Logging.delete_match_week_log(match_week_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_match_week_log!(match_week_log.date)
      end

      assert Logging.get_match_week_log(match_week_log.date) == nil
    end

    test "change_match_week_log/1 returns a match_week_log changeset" do
      match_week_log = LoggingFixtures.match_week_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_match_week_log(match_week_log)
    end
  end
end
