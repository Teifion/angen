defmodule Angen.Account.UserTokenQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Angen.Account.UserToken
  require Logger

  @spec user_token_query(Angen.query_args()) :: Ecto.Query.t()
  def user_token_query(args) do
    query = from(user_tokens in UserToken)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id_list) when is_list(id_list) do
    from user_tokens in query,
      where: user_tokens.id in ^id_list
  end

  def _where(query, :id, id) do
    from user_tokens in query,
      where: user_tokens.id == ^id
  end

  def _where(query, :user_id, user_id) do
    from user_tokens in query,
      where: user_tokens.user_id == ^user_id
  end

  def _where(query, :identifier_code, identifier_code) do
    from user_tokens in query,
      where: user_tokens.identifier_code == ^identifier_code
  end

  def _where(query, :renewal_code, renewal_code) do
    from user_tokens in query,
      where: user_tokens.renewal_code == ^renewal_code
  end

  def _where(query, :expires_after, timestamp) do
    from user_tokens in query,
      where: user_tokens.expires_at > ^timestamp
  end

  def _where(query, :inserted_after, timestamp) do
    from user_tokens in query,
      where: user_tokens.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from user_tokens in query,
      where: user_tokens.inserted_at < ^timestamp
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Name (A-Z)") do
    from user_tokens in query,
      order_by: [asc: user_tokens.name]
  end

  def _order_by(query, "Name (Z-A)") do
    from user_tokens in query,
      order_by: [desc: user_tokens.name]
  end

  def _order_by(query, "Newest first") do
    from user_tokens in query,
      order_by: [desc: user_tokens.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from user_tokens in query,
      order_by: [asc: user_tokens.inserted_at]
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :user) do
    from user_token in query,
      left_join: users in assoc(user_token, :user),
      preload: [user: users]
  end
end
