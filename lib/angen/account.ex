defmodule Angen.Account do
  @moduledoc """

  """

  # Delegating certain user calls to make it easier to copy-paste some of the auth stuff I've
  # used elsewhere. Long term this can be removed if anybody feels strongly about it.
  alias Teiserver.Account.{User, UserLib}

  @doc section: :user
  @spec list_users(list) :: [User.t()]
  defdelegate list_users(args), to: UserLib

  @doc section: :user
  @spec get_user_by_id(Teiserver.user_id()) :: User.t() | nil
  defdelegate get_user_by_id(user_id), to: UserLib

  @doc section: :user
  @spec get_user_by_name(String.t()) :: User.t() | nil
  defdelegate get_user_by_name(name), to: UserLib

  @doc section: :user
  @spec get_user_by_email(String.t()) :: User.t() | nil
  defdelegate get_user_by_email(email), to: UserLib

  @doc section: :user
  @spec valid_password?(User.t(), String.t()) :: boolean
  defdelegate valid_password?(user, plaintext_password), to: UserLib

  @doc section: :user
  @spec register_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate register_user(attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec create_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user(attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec update_user(User, map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user(user, attrs), to: UserLib

  @doc section: :user
  @spec update_password(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_password(user, attrs), to: UserLib

  @doc section: :user
  @spec update_limited_user(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_limited_user(user, attrs), to: UserLib

  @doc section: :user
  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user(user), to: UserLib

  @doc section: :user
  @spec generate_password() :: String.t()
  defdelegate generate_password(), to: UserLib

  @doc section: :user
  @spec generate_guest_name() :: String.t()
  defdelegate generate_guest_name(), to: UserLib

  @doc section: :user
  @spec restricted?(Teiserver.user_id() | User.t(), [String.t()] | String.t()) :: boolean
  defdelegate restricted?(user_or_user_id, permission_or_permissions), to: UserLib

  @spec deliver_user_confirmation_instructions(User.t(), function()) ::
          {:ok, map()}
  def deliver_user_confirmation_instructions(
        %User{} = _user,
        _confirmation_url_fun
      ) do
    {:ok, %{}}
  end

  # UserTokens
  alias Angen.Account.{UserToken, UserTokenLib, UserTokenQueries}

  @doc false
  @spec user_token_query(Angen.query_args()) :: Ecto.Query.t()
  defdelegate user_token_query(args), to: UserTokenQueries

  @doc section: :user_token
  @spec list_user_tokens(Angen.query_args()) :: [UserToken.t()]
  defdelegate list_user_tokens(args), to: UserTokenLib

  @doc section: :user_token
  @spec get_user_token!(UserToken.id()) :: UserToken.t()
  @spec get_user_token!(UserToken.id(), Angen.query_args()) :: UserToken.t()
  defdelegate get_user_token!(user_token_id, query_args \\ []), to: UserTokenLib

  @doc section: :user_token
  @spec get_user_token(UserToken.id()) :: UserToken.t() | nil
  @spec get_user_token(UserToken.id(), Angen.query_args()) :: UserToken.t() | nil
  defdelegate get_user_token(user_token_id, query_args \\ []), to: UserTokenLib

  @spec get_user_token_by_identifier(UserToken.identifier_code()) :: UserToken.t() | nil
  defdelegate get_user_token_by_identifier(identifier_code), to: UserTokenLib

  @spec get_user_token_by_identifier_renewal(
          UserToken.identifier_code(),
          UserToken.renewal_code()
        ) :: UserToken.t() | nil
  defdelegate get_user_token_by_identifier_renewal(identifier_code, renewal_code),
    to: UserTokenLib

  @doc section: :user_token
  @spec create_user_token(map) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user_token(attrs), to: UserTokenLib

  @doc section: :user_token
  @spec create_user_token(Angen.user_id(), String.t(), String.t(), String.t()) ::
          {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user_token(user_id, context, user_agent, ip), to: UserTokenLib

  @doc section: :user_token
  @spec update_user_token(UserToken, map) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user_token(user_token, attrs), to: UserTokenLib

  @doc section: :user_token
  @spec delete_user_token(UserToken.t()) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user_token(user_token), to: UserTokenLib

  @doc section: :user_token
  @spec change_user_token(UserToken.t()) :: Ecto.Changeset.t()
  @spec change_user_token(UserToken.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user_token(user_token, attrs \\ %{}), to: UserTokenLib

  @spec get_user_from_token_identifier(UserToken.identifier_code()) :: User.t() | nil
  def get_user_from_token_identifier(identifier_code) do
    token = get_user_token_by_identifier(identifier_code)
    token && get_user_by_id(token.user_id)
  end

  def get_or_create_anonymous_user() do
    case get_user_by_email("anonymous@angen") do
      nil ->
        {:ok, user} =
          create_user(%{
            name: "anonymous",
            email: "anonymous@angen",
            password: generate_password()
          })

        user

      user ->
        user
    end
  end
end
