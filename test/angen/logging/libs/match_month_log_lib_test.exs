defmodule Angen.MatchMonthLogLibTest do
  @moduledoc false
  alias Angen.Logging.MatchMonthLog
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

  describe "match_month_log" do
    alias Angen.Logging.MatchMonthLog

    test "match_month_log_query/0 returns a query" do
      q = Logging.match_month_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_month_log/0 returns match_month_log" do
      # No match_month_log yet
      assert Logging.list_match_month_logs([]) == []

      # Add a match_month_log
      LoggingFixtures.match_month_log_fixture()
      assert Logging.list_match_month_logs([]) != []
    end

    test "get_match_month_log!/1 and get_match_month_log/1 returns the match_month_log with given id" do
      match_month_log = LoggingFixtures.match_month_log_fixture()
      assert Logging.get_match_month_log!(match_month_log.date) == match_month_log
      assert Logging.get_match_month_log(match_month_log.date) == match_month_log
    end

    test "create_match_month_log/1 with valid data creates a match_month_log" do
      assert {:ok, %MatchMonthLog{} = match_month_log} =
               Logging.create_match_month_log(valid_attrs())

      assert match_month_log.data == %{"key" => 1}
    end

    test "create_match_month_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_match_month_log(invalid_attrs())
    end

    test "update_match_month_log/2 with valid data updates the match_month_log" do
      match_month_log = LoggingFixtures.match_month_log_fixture()

      assert {:ok, %MatchMonthLog{} = match_month_log} =
               Logging.update_match_month_log(match_month_log, update_attrs())

      assert match_month_log.data == %{"other-key" => 2}
    end

    test "update_match_month_log/2 with invalid data returns error changeset" do
      match_month_log = LoggingFixtures.match_month_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_match_month_log(match_month_log, invalid_attrs())

      assert match_month_log == Logging.get_match_month_log!(match_month_log.date)
    end

    test "delete_match_month_log/1 deletes the match_month_log" do
      match_month_log = LoggingFixtures.match_month_log_fixture()
      assert {:ok, %MatchMonthLog{}} = Logging.delete_match_month_log(match_month_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_match_month_log!(match_month_log.date)
      end

      assert Logging.get_match_month_log(match_month_log.date) == nil
    end

    test "change_match_month_log/1 returns a match_month_log changeset" do
      match_month_log = LoggingFixtures.match_month_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_match_month_log(match_month_log)
    end
  end
end
