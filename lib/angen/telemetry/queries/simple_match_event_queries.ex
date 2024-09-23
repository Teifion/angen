defmodule Angen.Telemetry.SimpleMatchEventQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Angen.Telemetry.SimpleMatchEvent
  require Logger

  @spec simple_match_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  def simple_match_event_query(args) do
    query = from(simple_match_events in SimpleMatchEvent)

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

  def _where(query, :id, id) do
    from(simple_match_events in query,
      where: simple_match_events.id in ^List.wrap(id)
    )
  end

  def _where(query, :type_id, type_id) do
    from(simple_match_events in query,
      where: simple_match_events.type_id in ^List.wrap(type_id)
    )
  end

  def _where(query, :user_id, user_id) do
    from(simple_match_events in query,
      where: simple_match_events.user_id in ^List.wrap(user_id)
    )
  end

  def _where(query, :match_id, match_id) do
    from(simple_match_events in query,
      where: simple_match_events.match_id in ^List.wrap(match_id)
    )
  end

  def _where(query, :after, timestamp) do
    from simple_match_events in query,
      where: simple_match_events.inserted_at > ^timestamp
  end

  def _where(query, :before, timestamp) do
    from simple_match_events in query,
      where: simple_match_events.inserted_at < ^timestamp
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
    from(simple_match_events in query,
      order_by: [desc: simple_match_events.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(simple_match_events in query,
      order_by: [asc: simple_match_events.inserted_at]
    )
  end

  def _order_by(query, "Game times seconds (low to high)") do
    from(simple_match_events in query,
      order_by: [asc: simple_match_events.game_time_seconds]
    )
  end

  def _order_by(query, "Game times seconds (high to low)") do
    from(simple_match_events in query,
      order_by: [desc: simple_match_events.game_time_seconds]
    )
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
  def _preload(query, :event_type) do
    from(events in query,
      left_join: event_types in assoc(events, :event_type),
      preload: [event_type: event_types]
    )
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :user) do
    from(events in query,
      left_join: users in assoc(events, :user),
      preload: [user: users]
    )
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :match) do
    from(events in query,
      left_join: matches in assoc(events, :match),
      preload: [match: matches]
    )
  end

  @spec simple_match_events_summary(list) :: map()
  def simple_match_events_summary(args) do
    query =
      from simple_match_events in SimpleMatchEvent,
        join: event_types in assoc(simple_match_events, :event_type),
        group_by: event_types.name,
        select: {event_types.name, count(simple_match_events.event_type_id)}

    query
    |> do_where(args)
    |> Repo.all()
    |> Map.new()
  end
end
