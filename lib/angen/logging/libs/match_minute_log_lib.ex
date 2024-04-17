defmodule Angen.Logging.MatchMinuteLogLib do
  @moduledoc """
  Library of match_minute_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{MatchMinuteLog, MatchMinuteLogQueries}

  @doc """
  Returns the list of match_minute_logs.

  ## Examples

      iex> list_match_minute_logs()
      [%MatchMinuteLog{}, ...]

  """
  @spec list_match_minute_logs(Teiserver.query_args()) :: [MatchMinuteLog.t()]
  def list_match_minute_logs(query_args) do
    query_args
    |> MatchMinuteLogQueries.match_minute_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_minute_log.

  Raises `Ecto.NoResultsError` if the MatchMinuteLog does not exist.

  ## Examples

      iex> get_match_minute_log!(123)
      %MatchMinuteLog{}

      iex> get_match_minute_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_minute_log!(DateTime.t()) :: MatchMinuteLog.t()
  @spec get_match_minute_log!(DateTime.t(), Teiserver.query_args()) :: MatchMinuteLog.t()
  def get_match_minute_log!(timestamp, query_args \\ []) do
    (query_args ++ [timestamp: timestamp])
    |> MatchMinuteLogQueries.match_minute_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_minute_log.

  Returns nil if the MatchMinuteLog does not exist.

  ## Examples

      iex> get_match_minute_log(123)
      %MatchMinuteLog{}

      iex> get_match_minute_log(456)
      nil

  """
  @spec get_match_minute_log(DateTime.t()) :: MatchMinuteLog.t() | nil
  @spec get_match_minute_log(DateTime.t(), Teiserver.query_args()) :: MatchMinuteLog.t() | nil
  def get_match_minute_log(timestamp, query_args \\ []) do
    (query_args ++ [timestamp: timestamp])
    |> MatchMinuteLogQueries.match_minute_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_minute_log.

  ## Examples

      iex> create_match_minute_log(%{field: value})
      {:ok, %MatchMinuteLog{}}

      iex> create_match_minute_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_minute_log(map) :: {:ok, MatchMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  def create_match_minute_log(attrs) do
    %MatchMinuteLog{}
    |> MatchMinuteLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_minute_log.

  ## Examples

      iex> update_match_minute_log(match_minute_log, %{field: new_value})
      {:ok, %MatchMinuteLog{}}

      iex> update_match_minute_log(match_minute_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_minute_log(MatchMinuteLog.t(), map) ::
          {:ok, MatchMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  def update_match_minute_log(%MatchMinuteLog{} = match_minute_log, attrs) do
    match_minute_log
    |> MatchMinuteLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_minute_log.

  ## Examples

      iex> delete_match_minute_log(match_minute_log)
      {:ok, %MatchMinuteLog{}}

      iex> delete_match_minute_log(match_minute_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_minute_log(MatchMinuteLog.t()) ::
          {:ok, MatchMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_minute_log(%MatchMinuteLog{} = match_minute_log) do
    Repo.delete(match_minute_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_minute_log changes.

  ## Examples

      iex> change_match_minute_log(match_minute_log)
      %Ecto.Changeset{data: %MatchMinuteLog{}}

  """
  @spec change_match_minute_log(MatchMinuteLog.t(), map) :: Ecto.Changeset.t()
  def change_match_minute_log(%MatchMinuteLog{} = match_minute_log, attrs \\ %{}) do
    MatchMinuteLog.changeset(match_minute_log, attrs)
  end
end
