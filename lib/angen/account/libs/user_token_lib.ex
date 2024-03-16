defmodule Angen.Account.UserTokenLib do
  @moduledoc """
  TODO: Library of user_token related functions.
  """
  alias Angen.Repo
  alias Angen.Account.{UserToken, UserTokenQueries}

  @doc """
  Returns the list of user_tokens.

  ## Examples

      iex> list_user_tokens()
      [%UserToken{}, ...]

  """
  @spec list_user_tokens(Angen.query_args()) :: [UserToken.t()]
  def list_user_tokens(query_args) do
    query_args
    |> UserTokenQueries.user_token_query()
    |> Repo.all()
  end

  @doc """
  Gets a single user_token.

  Raises `Ecto.NoResultsError` if the UserToken does not exist.

  ## Examples

      iex> get_user_token!(123)
      %UserToken{}

      iex> get_user_token!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_token!(UserToken.id()) :: UserToken.t()
  @spec get_user_token!(UserToken.id(), Angen.query_args()) :: UserToken.t()
  def get_user_token!(user_token_id, query_args \\ []) do
    (query_args ++ [id: user_token_id])
    |> UserTokenQueries.user_token_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single user_token.

  Returns nil if the UserToken does not exist.

  ## Examples

      iex> get_user_token(123)
      %UserToken{}

      iex> get_user_token(456)
      nil

  """
  @spec get_user_token(UserToken.id()) :: UserToken.t() | nil
  @spec get_user_token(UserToken.id(), Angen.query_args()) :: UserToken.t() | nil
  def get_user_token(user_token_id, query_args \\ []) do
    (query_args ++ [id: user_token_id])
    |> UserTokenQueries.user_token_query()
    |> Repo.one()
  end

  @doc """
  Gets a single user_token by the identifier_code.

  Returns nil if the UserToken does not exist.

  ## Examples

      iex> get_user_token_by_identifier("abc")
      %UserToken{}

      iex> get_user_token_by_identifier("def")
      nil

  """
  @spec get_user_token_by_identifier(UserToken.identifier_code()) :: UserToken.t() | nil
  def get_user_token_by_identifier(identifier_code) do
    UserTokenQueries.user_token_query(where: [identifier_code: identifier_code], preload: [:user])
    |> Repo.one()
  end

  @doc """
  Gets a single user_token by the renewal_code.

  Returns nil if the UserToken does not exist.

  ## Examples

      iex> get_user_token_by_renewal("abc")
      %UserToken{}

      iex> get_user_token_by_renewal("def")
      nil

  """
  @spec get_user_token_by_renewal(UserToken.renewal_code()) :: UserToken.t() | nil
  def get_user_token_by_renewal(renewal_code) do
    UserTokenQueries.user_token_query(where: [renewal_code: renewal_code], preload: [:user])
    |> Repo.one()
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  @spec get_user_by_session_token(UserToken.t()) :: UserToken.t() | nil
  def get_user_by_session_token(%{identifier_code: identifier_code, user_id: user_id}) do
    UserTokenQueries.user_token_query(
      where: [
        user_id: user_id,
        identifier_code: identifier_code,
        expires_after: Timex.now()
      ],
      preload: [:user]
    )
    |> Repo.one()
  end
  def get_user_by_session_token(_), do: nil

  @doc """
  Creates a user_token.

  ## Examples

      iex> create_user_token(%{field: value})
      {:ok, %UserToken{}}

      iex> create_user_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user_token(map) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  def create_user_token(attrs) do
    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user_token.

  ## Examples

      iex> create_user_token("user-uuid", "clientapp v1.2", "123.456.789.012")
      {:ok, %UserToken{}}

      iex> create_user_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user_token(Teiserver.user_id(), String.t(), String.t(), String.t()) ::
          {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  def create_user_token(user_id, context, user_agent, ip) do
    %UserToken{}
    |> UserToken.changeset(%{
      user_id: user_id,
      identifier_code: generate_code(),
      renewal_code: generate_code(),
      context: context,
      user_agent: user_agent,
      ip: ip,
      expires_at: Timex.now() |> Timex.shift(days: 31)
    })
    |> Repo.insert()
  end

  @doc """
  Updates a user_token.

  ## Examples

      iex> update_user_token(user_token, %{field: new_value})
      {:ok, %UserToken{}}

      iex> update_user_token(user_token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_token(UserToken.t(), map) ::
          {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  def update_user_token(%UserToken{} = user_token, attrs) do
    user_token
    |> UserToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_token.

  ## Examples

      iex> delete_user_token(user_token)
      {:ok, %UserToken{}}

      iex> delete_user_token(user_token)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user_token(UserToken.t()) :: {:ok, UserToken.t()} | {:error, Ecto.Changeset.t()}
  def delete_user_token(%UserToken{} = user_token) do
    Repo.delete(user_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_token changes.

  ## Examples

      iex> change_user_token(user_token)
      %Ecto.Changeset{data: %UserToken{}}

  """
  @spec change_user_token(UserToken.t(), map) :: Ecto.Changeset.t()
  def change_user_token(%UserToken{} = user_token, attrs \\ %{}) do
    UserToken.changeset(user_token, attrs)
  end

  @doc """
  Securely generates a random string of characters
  """
  @spec generate_code() :: String.t()
  @spec generate_code(non_neg_integer()) :: String.t()
  def generate_code(length \\ 255) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64(padding: false)
    |> binary_part(0, length)
  end
end
