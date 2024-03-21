defmodule Angen.DevSupport.BotLib do
  @moduledoc """
  Functions for internal bot accounts
  """
  alias Teiserver.Account

  @doc """
  Either returns or creates a bot account for this name
  """
  @spec get_or_create_bot_account(String.t()) :: Account.User.t()
  @spec get_or_create_bot_account(String.t(), [String.t()]) :: Account.User.t()
  def get_or_create_bot_account(name, groups \\ []) do
    case Account.get_user_by_name(name) do
      nil ->
        create_bot_account(name, groups)

      user ->
        update_bot_account(user, groups)
    end
  end

  defp create_bot_account(name, groups) do
    {:ok, user} = Account.create_user(%{
      "name" => name,
      "email" => email_from_name(name),
      "password" => Account.generate_password(),
      "groups" => ["integration" | groups]
    })
    user
  end

  defp update_bot_account(user, groups) do
    {:ok, user} = Account.update_user(user, %{
      "groups" => ["integration" | groups]
    })
    user
  end

  defp email_from_name(name) do
    sname = name
      |> String.trim()
      |> String.replace(" ", "")
      |> String.replace("@", "")

    "#{sname}@integration-testing"
  end
end
