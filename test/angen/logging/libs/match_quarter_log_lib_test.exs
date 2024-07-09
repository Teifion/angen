defmodule Angen.GameQuarterLogLibTest do
  @moduledoc false
  alias Angen.Logging.GameQuarterLog
  alias Angen.Logging
  use Angen.DataCase, async: true

  alias Angen.Fixtures.LoggingFixtures

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

  describe "game_quarter_log" do
    alias Angen.Logging.GameQuarterLog

    test "game_quarter_log_query/0 returns a query" do
      q = Logging.game_quarter_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_game_quarter_log/0 returns game_quarter_log" do
      # No game_quarter_log yet
      assert Logging.list_game_quarter_logs([]) == []

      # Add a game_quarter_log
      LoggingFixtures.game_quarter_log_fixture()
      assert Logging.list_game_quarter_logs([]) != []
    end

    test "get_game_quarter_log!/1 and get_game_quarter_log/1 returns the game_quarter_log with given id" do
      game_quarter_log = LoggingFixtures.game_quarter_log_fixture()
      assert Logging.get_game_quarter_log!(game_quarter_log.date) == game_quarter_log
      assert Logging.get_game_quarter_log(game_quarter_log.date) == game_quarter_log
    end

    test "create_game_quarter_log/1 with valid data creates a game_quarter_log" do
      assert {:ok, %GameQuarterLog{} = game_quarter_log} =
               Logging.create_game_quarter_log(valid_attrs())

      assert game_quarter_log.data == %{"key" => 1}
    end

    test "create_game_quarter_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_game_quarter_log(invalid_attrs())
    end

    test "update_game_quarter_log/2 with valid data updates the game_quarter_log" do
      game_quarter_log = LoggingFixtures.game_quarter_log_fixture()

      assert {:ok, %GameQuarterLog{} = game_quarter_log} =
               Logging.update_game_quarter_log(game_quarter_log, update_attrs())

      assert game_quarter_log.data == %{"other-key" => 2}
    end

    test "update_game_quarter_log/2 with invalid data returns error changeset" do
      game_quarter_log = LoggingFixtures.game_quarter_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_game_quarter_log(game_quarter_log, invalid_attrs())

      assert game_quarter_log == Logging.get_game_quarter_log!(game_quarter_log.date)
    end

    test "delete_game_quarter_log/1 deletes the game_quarter_log" do
      game_quarter_log = LoggingFixtures.game_quarter_log_fixture()
      assert {:ok, %GameQuarterLog{}} = Logging.delete_game_quarter_log(game_quarter_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_game_quarter_log!(game_quarter_log.date)
      end

      assert Logging.get_game_quarter_log(game_quarter_log.date) == nil
    end

    test "change_game_quarter_log/1 returns a game_quarter_log changeset" do
      game_quarter_log = LoggingFixtures.game_quarter_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_game_quarter_log(game_quarter_log)
    end
  end
end
