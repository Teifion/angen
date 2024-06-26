defmodule Angen.Logging.ServerYearLogLib do
  @moduledoc """
  Library of server_year_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerYearLog, ServerYearLogQueries}

  @doc """
  Returns the list of server_year_logs.

  ## Examples

      iex> list_server_year_logs()
      [%ServerYearLog{}, ...]

  """
  @spec list_server_year_logs(Teiserver.query_args()) :: [ServerYearLog.t()]
  def list_server_year_logs(query_args) do
    query_args
    |> ServerYearLogQueries.server_year_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_year_log.

  Raises `Ecto.NoResultsError` if the ServerYearLog does not exist.

  ## Examples

      iex> get_server_year_log!(123)
      %ServerYearLog{}

      iex> get_server_year_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_year_log!(Date.t()) :: ServerYearLog.t()
  @spec get_server_year_log!(Date.t(), Teiserver.query_args()) :: ServerYearLog.t()
  def get_server_year_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerYearLogQueries.server_year_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_year_log.

  Returns nil if the ServerYearLog does not exist.

  ## Examples

      iex> get_server_year_log(123)
      %ServerYearLog{}

      iex> get_server_year_log(456)
      nil

  """
  @spec get_server_year_log(Date.t()) :: ServerYearLog.t() | nil
  @spec get_server_year_log(Date.t(), Teiserver.query_args()) :: ServerYearLog.t() | nil
  def get_server_year_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerYearLogQueries.server_year_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_server_year_log_date() :: Date.t() | nil
  def get_last_server_year_log_date() do
    log =
      ServerYearLogQueries.server_year_log_query(
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
  Creates a server_year_log.

  ## Examples

      iex> create_server_year_log(%{field: value})
      {:ok, %ServerYearLog{}}

      iex> create_server_year_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_year_log(map) :: {:ok, ServerYearLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_year_log(attrs) do
    %ServerYearLog{}
    |> ServerYearLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_year_log.

  ## Examples

      iex> update_server_year_log(server_year_log, %{field: new_value})
      {:ok, %ServerYearLog{}}

      iex> update_server_year_log(server_year_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_year_log(ServerYearLog.t(), map) ::
          {:ok, ServerYearLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_year_log(%ServerYearLog{} = server_year_log, attrs) do
    server_year_log
    |> ServerYearLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_year_log.

  ## Examples

      iex> delete_server_year_log(server_year_log)
      {:ok, %ServerYearLog{}}

      iex> delete_server_year_log(server_year_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_year_log(ServerYearLog.t()) ::
          {:ok, ServerYearLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_year_log(%ServerYearLog{} = server_year_log) do
    Repo.delete(server_year_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_year_log changes.

  ## Examples

      iex> change_server_year_log(server_year_log)
      %Ecto.Changeset{data: %ServerYearLog{}}

  """
  @spec change_server_year_log(ServerYearLog.t(), map) :: Ecto.Changeset.t()
  def change_server_year_log(%ServerYearLog{} = server_year_log, attrs \\ %{}) do
    ServerYearLog.changeset(server_year_log, attrs)
  end
end
