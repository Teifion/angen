defmodule Angen.MatchMinuteLogLibTest do
  @moduledoc false
  alias Angen.Logging.MatchMinuteLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.LoggingFixtures

  @node "test-node"
  @updated_node "updated-test-node"

  defp valid_attrs do
    %{
      timestamp: Timex.now(),
      node: @node,
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      timestamp: Timex.now() |> Timex.shift(minutes: 1),
      node: @updated_node,
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

  describe "match_minute_log" do
    alias Angen.Logging.MatchMinuteLog

    test "match_minute_log_query/0 returns a query" do
      q = Logging.match_minute_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_minute_log/0 returns match_minute_log" do
      # No match_minute_log yet
      assert Logging.list_match_minute_logs([]) == []

      # Add a match_minute_log
      LoggingFixtures.match_minute_log_fixture()
      assert Logging.list_match_minute_logs([]) != []
    end

    test "get_match_minute_log!/1 and get_match_minute_log/1 returns the match_minute_log with given id" do
      match_minute_log = LoggingFixtures.match_minute_log_fixture()
      assert Logging.get_match_minute_log(match_minute_log.timestamp, @node) == match_minute_log
    end

    test "create_match_minute_log/1 with valid data creates a match_minute_log" do
      assert {:ok, %MatchMinuteLog{} = match_minute_log} =
               Logging.create_match_minute_log(valid_attrs())

      assert match_minute_log.data == %{"key" => 1}
    end

    test "create_match_minute_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_match_minute_log(invalid_attrs())
    end

    test "update_match_minute_log/2 with valid data updates the match_minute_log" do
      match_minute_log = LoggingFixtures.match_minute_log_fixture()

      assert {:ok, %MatchMinuteLog{} = match_minute_log} =
               Logging.update_match_minute_log(match_minute_log, update_attrs())

      assert match_minute_log.data == %{"other-key" => 2}
    end

    test "update_match_minute_log/2 with invalid data returns error changeset" do
      match_minute_log = LoggingFixtures.match_minute_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_match_minute_log(match_minute_log, invalid_attrs())

      assert match_minute_log == Logging.get_match_minute_log(match_minute_log.timestamp, @node)
    end

    test "delete_match_minute_log/1 deletes the match_minute_log" do
      match_minute_log = LoggingFixtures.match_minute_log_fixture()
      assert {:ok, %MatchMinuteLog{}} = Logging.delete_match_minute_log(match_minute_log)

      assert Logging.get_match_minute_log(match_minute_log.timestamp, @node) == nil
    end

    test "change_match_minute_log/1 returns a match_minute_log changeset" do
      match_minute_log = LoggingFixtures.match_minute_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_match_minute_log(match_minute_log)
    end
  end
end
