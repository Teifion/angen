defmodule Angen.Logging.MatchWeekLogQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Angen.Logging.MatchWeekLog
  require Logger

  @spec match_week_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_week_log_query(args) do
    query = from(match_week_logs in MatchWeekLog)

    query
    |> do_where(date: args[:date])
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

  def _where(query, :node, node) do
    from(match_week_logs in query,
      where: match_week_logs.node in ^List.wrap(node)
    )
  end

  def _where(query, :date, date) do
    from(match_week_logs in query,
      where: match_week_logs.date == ^date
    )
  end

  def _where(query, :year, year) do
    from(match_week_logs in query,
      where: match_week_logs.year == ^year
    )
  end

  def _where(query, :week, week) do
    from(match_week_logs in query,
      where: match_week_logs.week == ^week
    )
  end

  def _where(query, :after, timestamp) do
    from(match_week_logs in query,
      where: match_week_logs.date >= ^timestamp
    )
  end

  def _where(query, :before, timestamp) do
    from(match_week_logs in query,
      where: match_week_logs.date < ^timestamp
    )
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
    from(match_week_logs in query,
      order_by: [desc: match_week_logs.date]
    )
  end

  def _order_by(query, "Oldest first") do
    from(match_week_logs in query,
      order_by: [asc: match_week_logs.date]
    )
  end
end
