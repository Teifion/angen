defmodule Angen.Logging.ServerWeekLogLib do
  @moduledoc """
  Library of server_week_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerWeekLog, ServerWeekLogQueries}

  @doc """
  Returns the list of server_week_logs.

  ## Examples

      iex> list_server_week_logs()
      [%ServerWeekLog{}, ...]

  """
  @spec list_server_week_logs(Teiserver.query_args()) :: [ServerWeekLog.t()]
  def list_server_week_logs(query_args) do
    query_args
    |> ServerWeekLogQueries.server_week_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_week_log.

  Raises `Ecto.NoResultsError` if the ServerWeekLog does not exist.

  ## Examples

      iex> get_server_week_log!(123)
      %ServerWeekLog{}

      iex> get_server_week_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_week_log!(Date.t()) :: ServerWeekLog.t()
  @spec get_server_week_log!(Date.t(), Teiserver.query_args()) :: ServerWeekLog.t()
  def get_server_week_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerWeekLogQueries.server_week_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_week_log.

  Returns nil if the ServerWeekLog does not exist.

  ## Examples

      iex> get_server_week_log(123)
      %ServerWeekLog{}

      iex> get_server_week_log(456)
      nil

  """
  @spec get_server_week_log(Date.t()) :: ServerWeekLog.t() | nil
  @spec get_server_week_log(Date.t(), Teiserver.query_args()) :: ServerWeekLog.t() | nil
  def get_server_week_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerWeekLogQueries.server_week_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_server_week_log_date() :: Date.t() | nil
  def get_last_server_week_log_date() do
    log =
      ServerWeekLogQueries.server_week_log_query(
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
  Creates a server_week_log.

  ## Examples

      iex> create_server_week_log(%{field: value})
      {:ok, %ServerWeekLog{}}

      iex> create_server_week_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_week_log(map) :: {:ok, ServerWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_week_log(attrs) do
    %ServerWeekLog{}
    |> ServerWeekLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_week_log.

  ## Examples

      iex> update_server_week_log(server_week_log, %{field: new_value})
      {:ok, %ServerWeekLog{}}

      iex> update_server_week_log(server_week_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_week_log(ServerWeekLog.t(), map) ::
          {:ok, ServerWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_week_log(%ServerWeekLog{} = server_week_log, attrs) do
    server_week_log
    |> ServerWeekLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_week_log.

  ## Examples

      iex> delete_server_week_log(server_week_log)
      {:ok, %ServerWeekLog{}}

      iex> delete_server_week_log(server_week_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_week_log(ServerWeekLog.t()) ::
          {:ok, ServerWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_week_log(%ServerWeekLog{} = server_week_log) do
    Repo.delete(server_week_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_week_log changes.

  ## Examples

      iex> change_server_week_log(server_week_log)
      %Ecto.Changeset{data: %ServerWeekLog{}}

  """
  @spec change_server_week_log(ServerWeekLog.t(), map) :: Ecto.Changeset.t()
  def change_server_week_log(%ServerWeekLog{} = server_week_log, attrs \\ %{}) do
    ServerWeekLog.changeset(server_week_log, attrs)
  end
end
