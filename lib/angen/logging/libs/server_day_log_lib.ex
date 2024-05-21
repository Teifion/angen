defmodule Angen.Logging.ServerDayLogLib do
  @moduledoc """
  Library of server_day_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerDayLog, ServerDayLogQueries}

  @doc """
  Returns the list of server_day_logs.

  ## Examples

      iex> list_server_day_logs()
      [%ServerDayLog{}, ...]

  """
  @spec list_server_day_logs(Teiserver.query_args()) :: [ServerDayLog.t()]
  def list_server_day_logs(query_args) do
    query_args
    |> ServerDayLogQueries.server_day_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_day_log.

  Raises `Ecto.NoResultsError` if the ServerDayLog does not exist.

  ## Examples

      iex> get_server_day_log!(123)
      %ServerDayLog{}

      iex> get_server_day_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_day_log!(Date.t(), Teiserver.query_args()) :: ServerDayLog.t()
  def get_server_day_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerDayLogQueries.server_day_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_day_log.

  Returns nil if the ServerDayLog does not exist.

  ## Examples

      iex> get_server_day_log(123)
      %ServerDayLog{}

      iex> get_server_day_log(456)
      nil

  """
  @spec get_server_day_log(Date.t(), Teiserver.query_args()) :: ServerDayLog.t() | nil
  def get_server_day_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerDayLogQueries.server_day_log_query()
    |> Repo.one()
  end


  @doc """
  Gets the date of the last ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_server_day_log_date() :: Date.t() | nil
  def get_last_server_day_log_date() do
    ServerDayLogQueries.server_day_log_query(
      order_by: "Newest first",
      select: [:date],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a server_day_log.

  ## Examples

      iex> create_server_day_log(%{field: value})
      {:ok, %ServerDayLog{}}

      iex> create_server_day_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_day_log(map) :: {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_day_log(attrs) do
    %ServerDayLog{}
    |> ServerDayLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_day_log.

  ## Examples

      iex> update_server_day_log(server_day_log, %{field: new_value})
      {:ok, %ServerDayLog{}}

      iex> update_server_day_log(server_day_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_day_log(ServerDayLog.t(), map) ::
          {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_day_log(%ServerDayLog{} = server_day_log, attrs) do
    server_day_log
    |> ServerDayLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_day_log.

  ## Examples

      iex> delete_server_day_log(server_day_log)
      {:ok, %ServerDayLog{}}

      iex> delete_server_day_log(server_day_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_day_log(ServerDayLog.t()) ::
          {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_day_log(%ServerDayLog{} = server_day_log) do
    Repo.delete(server_day_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_day_log changes.

  ## Examples

      iex> change_server_day_log(server_day_log)
      %Ecto.Changeset{data: %ServerDayLog{}}

  """
  @spec change_server_day_log(ServerDayLog.t(), map) :: Ecto.Changeset.t()
  def change_server_day_log(%ServerDayLog{} = server_day_log, attrs \\ %{}) do
    ServerDayLog.changeset(server_day_log, attrs)
  end
end
