defmodule Angen.Logging.ServerQuarterLogQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Angen.Logging.ServerQuarterLog
  require Logger

  @spec server_quarter_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  def server_quarter_log_query(args) do
    query = from(server_quarter_logs in ServerQuarterLog)

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

  def _where(query, :date, date) do
    from(server_quarter_logs in query,
      where: server_quarter_logs.date == ^date
    )
  end

  def _where(query, :year, year) do
    from(server_quarter_logs in query,
      where: server_quarter_logs.year == ^year
    )
  end

  def _where(query, :quarter, quarter) do
    from(server_quarter_logs in query,
      where: server_quarter_logs.quarter == ^quarter
    )
  end

  def _where(query, :after, timestamp) do
    from(server_quarter_logs in query,
      where: server_quarter_logs.date >= ^timestamp
    )
  end

  def _where(query, :before, timestamp) do
    from(server_quarter_logs in query,
      where: server_quarter_logs.date < ^timestamp
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
    from(server_quarter_logs in query,
      order_by: [desc: server_quarter_logs.date]
    )
  end

  def _order_by(query, "Oldest first") do
    from(server_quarter_logs in query,
      order_by: [asc: server_quarter_logs.date]
    )
  end
end
