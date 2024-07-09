defmodule Angen.GameDayLogLibTest do
  @moduledoc false
  alias Angen.Logging.GameDayLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

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

  describe "game_day_log" do
    alias Angen.Logging.GameDayLog

    test "game_day_log_query/0 returns a query" do
      q = Logging.game_day_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_game_day_log/0 returns game_day_log" do
      # No game_day_log yet
      assert Logging.list_game_day_logs([]) == []

      # Add a game_day_log
      LoggingFixtures.game_day_log_fixture()
      assert Logging.list_game_day_logs([]) != []
    end

    test "get_game_day_log!/1 and get_game_day_log/1 returns the game_day_log with given id" do
      game_day_log = LoggingFixtures.game_day_log_fixture()
      assert Logging.get_game_day_log!(game_day_log.date) == game_day_log
      assert Logging.get_game_day_log(game_day_log.date) == game_day_log
    end

    test "create_game_day_log/1 with valid data creates a game_day_log" do
      assert {:ok, %GameDayLog{} = game_day_log} =
               Logging.create_game_day_log(valid_attrs())

      assert game_day_log.data == %{"key" => 1}
    end

    test "create_game_day_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_game_day_log(invalid_attrs())
    end

    test "update_game_day_log/2 with valid data updates the game_day_log" do
      game_day_log = LoggingFixtures.game_day_log_fixture()

      assert {:ok, %GameDayLog{} = game_day_log} =
               Logging.update_game_day_log(game_day_log, update_attrs())

      assert game_day_log.data == %{"other-key" => 2}
    end

    test "update_game_day_log/2 with invalid data returns error changeset" do
      game_day_log = LoggingFixtures.game_day_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_game_day_log(game_day_log, invalid_attrs())

      assert game_day_log == Logging.get_game_day_log!(game_day_log.date)
    end

    test "delete_game_day_log/1 deletes the game_day_log" do
      game_day_log = LoggingFixtures.game_day_log_fixture()
      assert {:ok, %GameDayLog{}} = Logging.delete_game_day_log(game_day_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_game_day_log!(game_day_log.date)
      end

      assert Logging.get_game_day_log(game_day_log.date) == nil
    end

    test "change_game_day_log/1 returns a game_day_log changeset" do
      game_day_log = LoggingFixtures.game_day_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_game_day_log(game_day_log)
    end
  end
end
