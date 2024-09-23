defmodule Angen.GameWeekLogQueriesTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Logging.GameWeekLogQueries

  describe "queries" do
    @empty_query GameWeekLogQueries.game_week_log_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        GameWeekLogQueries.game_week_log_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        GameWeekLogQueries.game_week_log_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        GameWeekLogQueries.game_week_log_query(
          where: [
            date: DateTimeHelper.today(),
            year: 123,
            week: 123,
            after: DateTime.utc_now(),
            before: DateTime.utc_now()
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: []
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
