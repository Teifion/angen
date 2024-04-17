defmodule Angen.ServerMonthLogQueriesTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Logging.ServerMonthLogQueries

  describe "queries" do
    @empty_query ServerMonthLogQueries.server_month_log_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        ServerMonthLogQueries.server_month_log_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        ServerMonthLogQueries.server_month_log_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        ServerMonthLogQueries.server_month_log_query(
          where: [
            date: Timex.today(),
            year: 123,
            month: 123,
            after: Timex.now(),
            before: Timex.now()
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
