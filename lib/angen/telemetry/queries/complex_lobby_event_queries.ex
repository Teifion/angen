defmodule Angen.Telemetry.ComplexLobbyEventQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Angen.Telemetry.ComplexLobbyEvent
  require Logger

  @spec complex_lobby_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  def complex_lobby_event_query(args) do
    query = from(complex_lobby_events in ComplexLobbyEvent)

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

  def _where(query, :id, id) do
    from(complex_lobby_events in query,
      where: complex_lobby_events.id in ^List.wrap(id)
    )
  end

  def _where(query, :type_id, type_id) do
    from(complex_lobby_events in query,
      where: complex_lobby_events.type_id in ^List.wrap(type_id)
    )
  end

  def _where(query, :user_id, user_id) do
    from(complex_lobby_events in query,
      where: complex_lobby_events.user_id in ^List.wrap(user_id)
    )
  end

  def _where(query, :lobby_id, lobby_id) do
    from(complex_lobby_events in query,
      where: complex_lobby_events.lobby_id in ^List.wrap(lobby_id)
    )
  end

  def _where(query, :after, timestamp) do
    from complex_lobby_events in query,
      where: complex_lobby_events.inserted_at > ^Timex.to_datetime(timestamp)
  end

  def _where(query, :before, timestamp) do
    from complex_lobby_events in query,
      where: complex_lobby_events.inserted_at < ^Timex.to_datetime(timestamp)
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Newest first") do
    from(complex_lobby_events in query,
      order_by: [desc: complex_lobby_events.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(complex_lobby_events in query,
      order_by: [asc: complex_lobby_events.inserted_at]
    )
  end

  @spec complex_lobby_events_summary(list) :: map()
  def complex_lobby_events_summary(args) do
    query =
      from complex_lobby_events in ComplexLobbyEvent,
        join: event_types in assoc(complex_lobby_events, :event_type),
        group_by: event_types.name,
        select: {event_types.name, count(complex_lobby_events.event_type_id)}

    query
    |> do_where(args)
    |> Repo.all()
    |> Map.new()
  end
end
