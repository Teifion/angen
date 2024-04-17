defmodule Angen.MatchYearLogLibTest do
  @moduledoc false
  alias Angen.Logging.MatchYearLog
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

  describe "match_year_log" do
    alias Angen.Logging.MatchYearLog

    test "match_year_log_query/0 returns a query" do
      q = Logging.match_year_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_year_log/0 returns match_year_log" do
      # No match_year_log yet
      assert Logging.list_match_year_logs([]) == []

      # Add a match_year_log
      LoggingFixtures.match_year_log_fixture()
      assert Logging.list_match_year_logs([]) != []
    end

    test "get_match_year_log!/1 and get_match_year_log/1 returns the match_year_log with given id" do
      match_year_log = LoggingFixtures.match_year_log_fixture()
      assert Logging.get_match_year_log!(match_year_log.date) == match_year_log
      assert Logging.get_match_year_log(match_year_log.date) == match_year_log
    end

    test "create_match_year_log/1 with valid data creates a match_year_log" do
      assert {:ok, %MatchYearLog{} = match_year_log} =
               Logging.create_match_year_log(valid_attrs())

      assert match_year_log.data == %{"key" => 1}
    end

    test "create_match_year_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_match_year_log(invalid_attrs())
    end

    test "update_match_year_log/2 with valid data updates the match_year_log" do
      match_year_log = LoggingFixtures.match_year_log_fixture()

      assert {:ok, %MatchYearLog{} = match_year_log} =
               Logging.update_match_year_log(match_year_log, update_attrs())

      assert match_year_log.data == %{"other-key" => 2}
    end

    test "update_match_year_log/2 with invalid data returns error changeset" do
      match_year_log = LoggingFixtures.match_year_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_match_year_log(match_year_log, invalid_attrs())

      assert match_year_log == Logging.get_match_year_log!(match_year_log.date)
    end

    test "delete_match_year_log/1 deletes the match_year_log" do
      match_year_log = LoggingFixtures.match_year_log_fixture()
      assert {:ok, %MatchYearLog{}} = Logging.delete_match_year_log(match_year_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_match_year_log!(match_year_log.date)
      end

      assert Logging.get_match_year_log(match_year_log.date) == nil
    end

    test "change_match_year_log/1 returns a match_year_log changeset" do
      match_year_log = LoggingFixtures.match_year_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_match_year_log(match_year_log)
    end
  end
end
