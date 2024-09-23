defmodule Angen.UserTokenQueryTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Account.UserTokenQueries

  describe "queries" do
    @empty_query UserTokenQueries.user_token_query([])

    test "clauses" do
      # Null/empty values, shouldn't error but shouldn't generate a query
      null_values =
        UserTokenQueries.user_token_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        UserTokenQueries.user_token_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        UserTokenQueries.user_token_query(
          where: [
            id: [Teiserver.uuid(), Teiserver.uuid()],
            id: Teiserver.uuid(),
            context: ["abc", "def"],
            context: "Some name",
            identifier_code: "Some code",
            renewal_code: "Some code",
            expires_after: DateTime.utc_now(),
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now()
          ],
          order_by: [
            "Newest first",
            "Oldest first",
            "Most recently used",
            "Last recently used"
          ],
          preload: [:user],
          limit: :infinity
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
