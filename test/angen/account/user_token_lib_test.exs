defmodule Angen.UserTokenLibTest do
  @moduledoc false
  alias Angen.Account.UserToken
  alias Angen.Account
  use Angen.DataCase, async: true

  alias Angen.Fixtures.AccountFixtures

  defp valid_attrs do
    %{
      user_id: AccountFixtures.user_fixture().id,
      identifier_code: "id-code",
      renewal_code: "ren-code",
      context: "context",
      user_agent: "agent",
      ip: "127.0.0.1",
      expires_at: Timex.now(),
      last_used_at: Timex.now()
    }
  end

  defp update_attrs do
    %{
      user_id: AccountFixtures.user_fixture().id,
      identifier_code: "id-code-updated",
      renewal_code: "ren-code-updated",
      context: "context-updated",
      user_agent: "agent-updated",
      ip: "192.168.0.1",
      expires_at: Timex.now(),
      last_used_at: Timex.now()
    }
  end

  defp invalid_attrs do
    %{
      user_id: nil,
      identifier_code: nil,
      renewal_code: nil,
      context: nil,
      user_agent: nil,
      ip: nil,
      expires_at: nil,
      last_used_at: nil
    }
  end

  describe "user_token" do
    test "user_token_query/0 returns a query" do
      q = Account.user_token_query([])
      assert %Ecto.Query{} = q
    end

    test "list_user_token/0 returns user_token" do
      # No user_token yet
      assert Account.list_user_tokens([]) == []

      # Add a user_token
      AccountFixtures.user_token_fixture()
      assert Account.list_user_tokens([]) != []
    end

    test "get_user_token!/1 and get_user_token/1 returns the user_token with given id" do
      user_token = AccountFixtures.user_token_fixture()
      assert Account.get_user_token!(user_token.id) == user_token
      assert Account.get_user_token(user_token.id) == user_token
    end

    test "create_user_token/1 with valid data creates a user_token" do
      assert {:ok, %UserToken{} = user_token} =
               Account.create_user_token(valid_attrs())

      assert user_token.identifier_code == "id-code"
    end

    test "create_user_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user_token(invalid_attrs())
    end

    test "update_user_token/2 with valid data updates the user_token" do
      user_token = AccountFixtures.user_token_fixture()

      assert {:ok, %UserToken{} = user_token} =
               Account.update_user_token(user_token, update_attrs())

      assert user_token.identifier_code == "id-code-updated"
    end

    test "update_user_token/2 with invalid data returns error changeset" do
      user_token = AccountFixtures.user_token_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Account.update_user_token(user_token, invalid_attrs())

      assert user_token == Account.get_user_token!(user_token.id)
    end

    test "delete_user_token/1 deletes the user_token" do
      user_token = AccountFixtures.user_token_fixture()
      assert {:ok, %UserToken{}} = Account.delete_user_token(user_token)

      assert_raise Ecto.NoResultsError, fn ->
        Account.get_user_token!(user_token.id)
      end

      assert Account.get_user_token(user_token.id) == nil
    end

    test "change_user_token/1 returns a user_token changeset" do
      user_token = AccountFixtures.user_token_fixture()
      assert %Ecto.Changeset{} = Account.change_user_token(user_token)
    end
  end
end
