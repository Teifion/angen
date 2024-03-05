defmodule Angen.Account do
  # UserTokens
  alias Angen.Account.{UserToken, UserTokenLib, UserTokenQueries}

  @doc false
  @spec user_token_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate user_token_query(args), to: UserTokenQueries

  @doc section: :user_token
  @spec list_user_tokens(Teiserver.query_args()) :: [UserToken.t]
  defdelegate list_user_tokens(args), to: UserTokenLib

  @doc section: :user_token
  @spec get_user_token!(UserToken.id()) :: UserToken.t
  @spec get_user_token!(UserToken.id(), Teiserver.query_args()) :: UserToken.t
  defdelegate get_user_token!(user_token_id, query_args \\ []), to: UserTokenLib

  @doc section: :user_token
  @spec get_user_token(UserToken.id()) :: UserToken.t | nil
  @spec get_user_token(UserToken.id(), Teiserver.query_args()) :: UserToken.t | nil
  defdelegate get_user_token(user_token_id, query_args \\ []), to: UserTokenLib

  @spec get_user_token_by_identifier(UserToken.identifier_code()) :: UserToken.t() | nil
  defdelegate get_user_token_by_identifier(identifier_code), to: UserTokenLib

  @spec get_user_token_by_renewal(UserToken.renewal_code()) :: UserToken.t() | nil
  defdelegate get_user_token_by_renewal(renewal_code), to: UserTokenLib

  @doc section: :user_token
  @spec create_user_token(map) :: {:ok, UserToken.t} | {:error, Ecto.Changeset.t()}
  defdelegate create_user_token(attrs), to: UserTokenLib

  @doc section: :user_token
  @spec create_user_token(Teiserver.user_id(), String.t(), String.t()) :: {:ok, UserToken.t} | {:error, Ecto.Changeset.t}
  defdelegate create_user_token(user_id, user_agent, ip), to: UserTokenLib

  @doc section: :user_token
  @spec update_user_token(UserToken, map) :: {:ok, UserToken.t} | {:error, Ecto.Changeset.t()}
  defdelegate update_user_token(user_token, attrs), to: UserTokenLib

  @doc section: :user_token
  @spec delete_user_token(UserToken.t) :: {:ok, UserToken.t} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user_token(user_token), to: UserTokenLib

  @doc section: :user_token
  @spec change_user_token(UserToken.t) :: Ecto.Changeset.t()
  @spec change_user_token(UserToken.t, map) :: Ecto.Changeset.t()
  defdelegate change_user_token(user_token, attrs \\ %{}), to: UserTokenLib

end
