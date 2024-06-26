defmodule Angen.Logging.ServerMonthLogLib do
  @moduledoc """
  Library of server_month_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerMonthLog, ServerMonthLogQueries}

  @doc """
  Returns the list of server_month_logs.

  ## Examples

      iex> list_server_month_logs()
      [%ServerMonthLog{}, ...]

  """
  @spec list_server_month_logs(Teiserver.query_args()) :: [ServerMonthLog.t()]
  def list_server_month_logs(query_args) do
    query_args
    |> ServerMonthLogQueries.server_month_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_month_log.

  Raises `Ecto.NoResultsError` if the ServerMonthLog does not exist.

  ## Examples

      iex> get_server_month_log!(123)
      %ServerMonthLog{}

      iex> get_server_month_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_month_log!(Date.t()) :: ServerMonthLog.t()
  @spec get_server_month_log!(Date.t(), Teiserver.query_args()) :: ServerMonthLog.t()
  def get_server_month_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerMonthLogQueries.server_month_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_month_log.

  Returns nil if the ServerMonthLog does not exist.

  ## Examples

      iex> get_server_month_log(123)
      %ServerMonthLog{}

      iex> get_server_month_log(456)
      nil

  """
  @spec get_server_month_log(Date.t()) :: ServerMonthLog.t() | nil
  @spec get_server_month_log(Date.t(), Teiserver.query_args()) :: ServerMonthLog.t() | nil
  def get_server_month_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerMonthLogQueries.server_month_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_server_month_log_date() :: Date.t() | nil
  def get_last_server_month_log_date() do
    log =
      ServerMonthLogQueries.server_month_log_query(
        order_by: "Newest first",
        select: [:date],
        limit: 1
      )
      |> Repo.one()

    case log do
      nil -> nil
      %{date: date} -> date
    end
  end

  @doc """
  Creates a server_month_log.

  ## Examples

      iex> create_server_month_log(%{field: value})
      {:ok, %ServerMonthLog{}}

      iex> create_server_month_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_month_log(map) :: {:ok, ServerMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_month_log(attrs) do
    %ServerMonthLog{}
    |> ServerMonthLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_month_log.

  ## Examples

      iex> update_server_month_log(server_month_log, %{field: new_value})
      {:ok, %ServerMonthLog{}}

      iex> update_server_month_log(server_month_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_month_log(ServerMonthLog.t(), map) ::
          {:ok, ServerMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_month_log(%ServerMonthLog{} = server_month_log, attrs) do
    server_month_log
    |> ServerMonthLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_month_log.

  ## Examples

      iex> delete_server_month_log(server_month_log)
      {:ok, %ServerMonthLog{}}

      iex> delete_server_month_log(server_month_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_month_log(ServerMonthLog.t()) ::
          {:ok, ServerMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_month_log(%ServerMonthLog{} = server_month_log) do
    Repo.delete(server_month_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_month_log changes.

  ## Examples

      iex> change_server_month_log(server_month_log)
      %Ecto.Changeset{data: %ServerMonthLog{}}

  """
  @spec change_server_month_log(ServerMonthLog.t(), map) :: Ecto.Changeset.t()
  def change_server_month_log(%ServerMonthLog{} = server_month_log, attrs \\ %{}) do
    ServerMonthLog.changeset(server_month_log, attrs)
  end
end
