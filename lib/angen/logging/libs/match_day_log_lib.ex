defmodule Angen.Logging.MatchDayLogLib do
  @moduledoc """
  Library of match_day_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{MatchDayLog, MatchDayLogQueries}

  @doc """
  Returns the list of match_day_logs.

  ## Examples

      iex> list_match_day_logs()
      [%MatchDayLog{}, ...]

  """
  @spec list_match_day_logs(Teiserver.query_args()) :: [MatchDayLog.t()]
  def list_match_day_logs(query_args) do
    query_args
    |> MatchDayLogQueries.match_day_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_day_log.

  Raises `Ecto.NoResultsError` if the MatchDayLog does not exist.

  ## Examples

      iex> get_match_day_log!(123)
      %MatchDayLog{}

      iex> get_match_day_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_day_log!(Date.t()) :: MatchDayLog.t()
  @spec get_match_day_log!(Date.t(), Teiserver.query_args()) :: MatchDayLog.t()
  def get_match_day_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchDayLogQueries.match_day_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_day_log.

  Returns nil if the MatchDayLog does not exist.

  ## Examples

      iex> get_match_day_log(123)
      %MatchDayLog{}

      iex> get_match_day_log(456)
      nil

  """
  @spec get_match_day_log(Date.t()) :: MatchDayLog.t() | nil
  @spec get_match_day_log(Date.t(), Teiserver.query_args()) :: MatchDayLog.t() | nil
  def get_match_day_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchDayLogQueries.match_day_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_day_log.

  ## Examples

      iex> create_match_day_log(%{field: value})
      {:ok, %MatchDayLog{}}

      iex> create_match_day_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_day_log(map) :: {:ok, MatchDayLog.t()} | {:error, Ecto.Changeset.t()}
  def create_match_day_log(attrs) do
    %MatchDayLog{}
    |> MatchDayLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_day_log.

  ## Examples

      iex> update_match_day_log(match_day_log, %{field: new_value})
      {:ok, %MatchDayLog{}}

      iex> update_match_day_log(match_day_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_day_log(MatchDayLog.t(), map) ::
          {:ok, MatchDayLog.t()} | {:error, Ecto.Changeset.t()}
  def update_match_day_log(%MatchDayLog{} = match_day_log, attrs) do
    match_day_log
    |> MatchDayLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_day_log.

  ## Examples

      iex> delete_match_day_log(match_day_log)
      {:ok, %MatchDayLog{}}

      iex> delete_match_day_log(match_day_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_day_log(MatchDayLog.t()) ::
          {:ok, MatchDayLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_day_log(%MatchDayLog{} = match_day_log) do
    Repo.delete(match_day_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_day_log changes.

  ## Examples

      iex> change_match_day_log(match_day_log)
      %Ecto.Changeset{data: %MatchDayLog{}}

  """
  @spec change_match_day_log(MatchDayLog.t(), map) :: Ecto.Changeset.t()
  def change_match_day_log(%MatchDayLog{} = match_day_log, attrs \\ %{}) do
    MatchDayLog.changeset(match_day_log, attrs)
  end
end
