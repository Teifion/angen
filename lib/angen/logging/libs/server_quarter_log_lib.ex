defmodule Angen.Logging.ServerQuarterLogLib do
  @moduledoc """
  Library of server_quarter_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerQuarterLog, ServerQuarterLogQueries}

  @doc """
  Returns the list of server_quarter_logs.

  ## Examples

      iex> list_server_quarter_logs()
      [%ServerQuarterLog{}, ...]

  """
  @spec list_server_quarter_logs(Teiserver.query_args()) :: [ServerQuarterLog.t()]
  def list_server_quarter_logs(query_args) do
    query_args
    |> ServerQuarterLogQueries.server_quarter_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_quarter_log.

  Raises `Ecto.NoResultsError` if the ServerQuarterLog does not exist.

  ## Examples

      iex> get_server_quarter_log!(123)
      %ServerQuarterLog{}

      iex> get_server_quarter_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_quarter_log!(Date.t()) :: ServerQuarterLog.t()
  @spec get_server_quarter_log!(Date.t(), Teiserver.query_args()) :: ServerQuarterLog.t()
  def get_server_quarter_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerQuarterLogQueries.server_quarter_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_quarter_log.

  Returns nil if the ServerQuarterLog does not exist.

  ## Examples

      iex> get_server_quarter_log(123)
      %ServerQuarterLog{}

      iex> get_server_quarter_log(456)
      nil

  """
  @spec get_server_quarter_log(Date.t()) :: ServerQuarterLog.t() | nil
  @spec get_server_quarter_log(Date.t(), Teiserver.query_args()) :: ServerQuarterLog.t() | nil
  def get_server_quarter_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerQuarterLogQueries.server_quarter_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_server_quarter_log_date() :: Date.t() | nil
  def get_last_server_quarter_log_date() do
    log =
      ServerQuarterLogQueries.server_quarter_log_query(
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
  Creates a server_quarter_log.

  ## Examples

      iex> create_server_quarter_log(%{field: value})
      {:ok, %ServerQuarterLog{}}

      iex> create_server_quarter_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_quarter_log(map) ::
          {:ok, ServerQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_quarter_log(attrs) do
    %ServerQuarterLog{}
    |> ServerQuarterLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_quarter_log.

  ## Examples

      iex> update_server_quarter_log(server_quarter_log, %{field: new_value})
      {:ok, %ServerQuarterLog{}}

      iex> update_server_quarter_log(server_quarter_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_quarter_log(ServerQuarterLog.t(), map) ::
          {:ok, ServerQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_quarter_log(%ServerQuarterLog{} = server_quarter_log, attrs) do
    server_quarter_log
    |> ServerQuarterLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_quarter_log.

  ## Examples

      iex> delete_server_quarter_log(server_quarter_log)
      {:ok, %ServerQuarterLog{}}

      iex> delete_server_quarter_log(server_quarter_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_quarter_log(ServerQuarterLog.t()) ::
          {:ok, ServerQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_quarter_log(%ServerQuarterLog{} = server_quarter_log) do
    Repo.delete(server_quarter_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_quarter_log changes.

  ## Examples

      iex> change_server_quarter_log(server_quarter_log)
      %Ecto.Changeset{data: %ServerQuarterLog{}}

  """
  @spec change_server_quarter_log(ServerQuarterLog.t(), map) :: Ecto.Changeset.t()
  def change_server_quarter_log(%ServerQuarterLog{} = server_quarter_log, attrs \\ %{}) do
    ServerQuarterLog.changeset(server_quarter_log, attrs)
  end
end
