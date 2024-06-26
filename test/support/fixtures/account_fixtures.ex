defmodule Angen.Fixtures.AccountFixtures do
  @moduledoc false
  alias Teiserver.Account.User

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
end
