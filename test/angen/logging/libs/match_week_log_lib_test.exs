defmodule Angen.GameWeekLogLibTest do
  @moduledoc false
  alias Angen.Logging.GameWeekLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

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

  describe "game_week_log" do
    alias Angen.Logging.GameWeekLog

    test "game_week_log_query/0 returns a query" do
      q = Logging.game_week_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_game_week_log/0 returns game_week_log" do
      # No game_week_log yet
      assert Logging.list_game_week_logs([]) == []

      # Add a game_week_log
      LoggingFixtures.game_week_log_fixture()
      assert Logging.list_game_week_logs([]) != []
    end

    test "get_game_week_log!/1 and get_game_week_log/1 returns the game_week_log with given id" do
      game_week_log = LoggingFixtures.game_week_log_fixture()
      assert Logging.get_game_week_log!(game_week_log.date) == game_week_log
      assert Logging.get_game_week_log(game_week_log.date) == game_week_log
    end

    test "create_game_week_log/1 with valid data creates a game_week_log" do
      assert {:ok, %GameWeekLog{} = game_week_log} =
               Logging.create_game_week_log(valid_attrs())

      assert game_week_log.data == %{"key" => 1}
    end

    test "create_game_week_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_game_week_log(invalid_attrs())
    end

    test "update_game_week_log/2 with valid data updates the game_week_log" do
      game_week_log = LoggingFixtures.game_week_log_fixture()

      assert {:ok, %GameWeekLog{} = game_week_log} =
               Logging.update_game_week_log(game_week_log, update_attrs())

      assert game_week_log.data == %{"other-key" => 2}
    end

    test "update_game_week_log/2 with invalid data returns error changeset" do
      game_week_log = LoggingFixtures.game_week_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_game_week_log(game_week_log, invalid_attrs())

      assert game_week_log == Logging.get_game_week_log!(game_week_log.date)
    end

    test "delete_game_week_log/1 deletes the game_week_log" do
      game_week_log = LoggingFixtures.game_week_log_fixture()
      assert {:ok, %GameWeekLog{}} = Logging.delete_game_week_log(game_week_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_game_week_log!(game_week_log.date)
      end

      assert Logging.get_game_week_log(game_week_log.date) == nil
    end

    test "change_game_week_log/1 returns a game_week_log changeset" do
      game_week_log = LoggingFixtures.game_week_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_game_week_log(game_week_log)
    end
  end
end
