defmodule Angen.Logging.ServerMinuteLogLib do
  @moduledoc """
  Library of server_minute_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerMinuteLog, ServerMinuteLogQueries}

  @segment_length 60
  @segment_count div(1440, @segment_length) - 1

  @doc """
  Returns the list of server_minute_logs.

  ## Examples

      iex> list_server_minute_logs()
      [%ServerMinuteLog{}, ...]

  """
  @spec list_server_minute_logs(Teiserver.query_args()) :: [ServerMinuteLog.t()]
  def list_server_minute_logs(query_args) do
    query_args
    |> ServerMinuteLogQueries.server_minute_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_minute_log.

  Returns nil if the ServerMinuteLog does not exist.

  ## Examples

      iex> get_server_minute_log(123)
      %ServerMinuteLog{}

      iex> get_server_minute_log(456)
      nil

  """
  @spec get_server_minute_log(DateTime.t(), String.t() | [String.t()], Teiserver.query_args()) :: ServerMinuteLog.t() | nil
  def get_server_minute_log(timestamp, node, query_args \\ []) do
    (query_args ++ [timestamp: timestamp, node: node])
    |> ServerMinuteLogQueries.server_minute_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the datetime of the first ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_first_server_minute_datetime() :: DateTime.t() | nil
  def get_first_server_minute_datetime() do
    log = ServerMinuteLogQueries.server_minute_log_query(
      order_by: "Oldest first",
      select: [:timestamp],
      limit: 1
    )
    |> Repo.one()

    if log, do: log.timestamp, else: nil
  end

  @doc """
  Creates a server_minute_log.

  ## Examples

      iex> create_server_minute_log(%{field: value})
      {:ok, %ServerMinuteLog{}}

      iex> create_server_minute_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_minute_log(map) :: {:ok, ServerMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_minute_log(attrs) do
    %ServerMinuteLog{}
    |> ServerMinuteLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_minute_log.

  ## Examples

      iex> update_server_minute_log(server_minute_log, %{field: new_value})
      {:ok, %ServerMinuteLog{}}

      iex> update_server_minute_log(server_minute_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_minute_log(ServerMinuteLog.t(), map) ::
          {:ok, ServerMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_minute_log(%ServerMinuteLog{} = server_minute_log, attrs) do
    server_minute_log
    |> ServerMinuteLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_minute_log.

  ## Examples

      iex> delete_server_minute_log(server_minute_log)
      {:ok, %ServerMinuteLog{}}

      iex> delete_server_minute_log(server_minute_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_minute_log(ServerMinuteLog.t()) ::
          {:ok, ServerMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_minute_log(%ServerMinuteLog{} = server_minute_log) do
    Repo.delete(server_minute_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_minute_log changes.

  ## Examples

      iex> change_server_minute_log(server_minute_log)
      %Ecto.Changeset{data: %ServerMinuteLog{}}

  """
  @spec change_server_minute_log(ServerMinuteLog.t(), map) :: Ecto.Changeset.t()
  def change_server_minute_log(%ServerMinuteLog{} = server_minute_log, attrs \\ %{}) do
    ServerMinuteLog.changeset(server_minute_log, attrs)
  end
end
