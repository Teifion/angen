defmodule Angen.Fixtures.AccountFixtures do
  @moduledoc false
  alias Teiserver.Account.User
  alias Angen.Account.UserToken

  @spec user_fixture() :: User.t()
  @spec user_fixture(map) :: User.t()
  def user_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    User.changeset(
      %User{},
      %{
        name: data[:name] || "user_name_#{r}",
        email: data[:email] || "user_email_#{r}",
        password: data[:password] || "password",
        groups: data[:groups] || [],
        permissions: data[:permissions] || [],
        restrictions: data[:restrictions] || []
      },
      :full
    )
    |> Angen.Repo.insert!()
  end

  @spec user_token_fixture() :: User.t()
  @spec user_token_fixture(map) :: User.t()
  def user_token_fixture(data \\ %{}) do
    UserToken.changeset(
      %UserToken{},
      %{
        user_id: data[:user_id] || user_fixture().id,
        identifier_code: data[:identifier_code] || "id-code-#{Teiserver.uuid()}",
        renewal_code: data[:renewal_code] || "ren-code-#{Teiserver.uuid()}",
        context: data[:context] || "context",
        user_agent: data[:user_agent] || "agent",
        ip: data[:ip] || "127.0.0.1",
        expires_at: data[:expires_at] || DateTime.utc_now() |> DateTime.shift(day: 1),
        last_used_at: data[:last_used_at] || nil
      }
    )
    |> Angen.Repo.insert!()
  end
end
