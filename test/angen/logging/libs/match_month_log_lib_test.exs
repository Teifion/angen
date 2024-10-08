defmodule Angen.GameMonthLogLibTest do
  @moduledoc false
  alias Angen.Logging.GameMonthLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

  defp valid_attrs do
    %{
      date: Angen.Helper.DateTimeHelper.today(),
      year: 1,
      month: 1,
      data: %{"key" => 1}
    }
  end

  defp update_attrs do
    %{
      date: Angen.Helper.DateTimeHelper.today() |> Date.shift(month: 1),
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

  describe "game_month_log" do
    alias Angen.Logging.GameMonthLog

    test "game_month_log_query/0 returns a query" do
      q = Logging.game_month_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_game_month_log/0 returns game_month_log" do
      # No game_month_log yet
      assert Logging.list_game_month_logs([]) == []

      # Add a game_month_log
      LoggingFixtures.game_month_log_fixture()
      assert Logging.list_game_month_logs([]) != []
    end

    test "get_game_month_log!/1 and get_game_month_log/1 returns the game_month_log with given id" do
      game_month_log = LoggingFixtures.game_month_log_fixture()
      assert Logging.get_game_month_log!(game_month_log.date) == game_month_log
      assert Logging.get_game_month_log(game_month_log.date) == game_month_log
    end

    test "create_game_month_log/1 with valid data creates a game_month_log" do
      assert {:ok, %GameMonthLog{} = game_month_log} =
               Logging.create_game_month_log(valid_attrs())

      assert game_month_log.data == %{"key" => 1}
    end

    test "create_game_month_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_game_month_log(invalid_attrs())
    end

    test "update_game_month_log/2 with valid data updates the game_month_log" do
      game_month_log = LoggingFixtures.game_month_log_fixture()

      assert {:ok, %GameMonthLog{} = game_month_log} =
               Logging.update_game_month_log(game_month_log, update_attrs())

      assert game_month_log.data == %{"other-key" => 2}
    end

    test "update_game_month_log/2 with invalid data returns error changeset" do
      game_month_log = LoggingFixtures.game_month_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_game_month_log(game_month_log, invalid_attrs())

      assert game_month_log == Logging.get_game_month_log!(game_month_log.date)
    end

    test "delete_game_month_log/1 deletes the game_month_log" do
      game_month_log = LoggingFixtures.game_month_log_fixture()
      assert {:ok, %GameMonthLog{}} = Logging.delete_game_month_log(game_month_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_game_month_log!(game_month_log.date)
      end

      assert Logging.get_game_month_log(game_month_log.date) == nil
    end

    test "change_game_month_log/1 returns a game_month_log changeset" do
      game_month_log = LoggingFixtures.game_month_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_game_month_log(game_month_log)
    end
  end
end
