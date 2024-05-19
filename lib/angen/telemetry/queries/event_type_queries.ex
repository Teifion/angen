defmodule Angen.Telemetry.EventTypeQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Angen.Telemetry.EventType
  require Logger

  @spec event_type_query(Teiserver.query_args()) :: Ecto.Query.t()
  def event_type_query(args) do
    query = from(event_types in EventType)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
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
    from(event_types in query,
      where: event_types.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(event_types in query,
      where: event_types.id == ^id
    )
  end

  def _where(query, :name, name) do
    from(event_types in query,
      where: event_types.name == ^name
    )
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
    from(event_types in query,
      order_by: [asc: event_types.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(event_types in query,
      order_by: [desc: event_types.name]
    )
  end
end
