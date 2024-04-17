defmodule Angen.MatchQuarterLogLibTest do
  @moduledoc false
  alias Angen.Logging.MatchQuarterLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.LoggingFixtures

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
      data: nil
    }
  end

  describe "match_quarter_log" do
    alias Angen.Logging.MatchQuarterLog

    test "match_quarter_log_query/0 returns a query" do
      q = Logging.match_quarter_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_quarter_log/0 returns match_quarter_log" do
      # No match_quarter_log yet
      assert Logging.list_match_quarter_logs([]) == []

      # Add a match_quarter_log
      LoggingFixtures.match_quarter_log_fixture()
      assert Logging.list_match_quarter_logs([]) != []
    end

    test "get_match_quarter_log!/1 and get_match_quarter_log/1 returns the match_quarter_log with given id" do
      match_quarter_log = LoggingFixtures.match_quarter_log_fixture()
      assert Logging.get_match_quarter_log!(match_quarter_log.date) == match_quarter_log
      assert Logging.get_match_quarter_log(match_quarter_log.date) == match_quarter_log
    end

    test "create_match_quarter_log/1 with valid data creates a match_quarter_log" do
      assert {:ok, %MatchQuarterLog{} = match_quarter_log} =
               Logging.create_match_quarter_log(valid_attrs())

      assert match_quarter_log.data == %{"key" => 1}
    end

    test "create_match_quarter_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_match_quarter_log(invalid_attrs())
    end

    test "update_match_quarter_log/2 with valid data updates the match_quarter_log" do
      match_quarter_log = LoggingFixtures.match_quarter_log_fixture()

      assert {:ok, %MatchQuarterLog{} = match_quarter_log} =
               Logging.update_match_quarter_log(match_quarter_log, update_attrs())

      assert match_quarter_log.data == %{"other-key" => 2}
    end

    test "update_match_quarter_log/2 with invalid data returns error changeset" do
      match_quarter_log = LoggingFixtures.match_quarter_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_match_quarter_log(match_quarter_log, invalid_attrs())

      assert match_quarter_log == Logging.get_match_quarter_log!(match_quarter_log.date)
    end

    test "delete_match_quarter_log/1 deletes the match_quarter_log" do
      match_quarter_log = LoggingFixtures.match_quarter_log_fixture()
      assert {:ok, %MatchQuarterLog{}} = Logging.delete_match_quarter_log(match_quarter_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_match_quarter_log!(match_quarter_log.date)
      end

      assert Logging.get_match_quarter_log(match_quarter_log.date) == nil
    end

    test "change_match_quarter_log/1 returns a match_quarter_log changeset" do
      match_quarter_log = LoggingFixtures.match_quarter_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_match_quarter_log(match_quarter_log)
    end
  end
end
