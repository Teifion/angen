defmodule Angen.Logging.MatchWeekLogLib do
  @moduledoc """
  Library of match_week_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{MatchWeekLog, MatchWeekLogQueries}

  @doc """
  Returns the list of match_week_logs.

  ## Examples

      iex> list_match_week_logs()
      [%MatchWeekLog{}, ...]

  """
  @spec list_match_week_logs(Teiserver.query_args()) :: [MatchWeekLog.t()]
  def list_match_week_logs(query_args) do
    query_args
    |> MatchWeekLogQueries.match_week_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_week_log.

  Raises `Ecto.NoResultsError` if the MatchWeekLog does not exist.

  ## Examples

      iex> get_match_week_log!(123)
      %MatchWeekLog{}

      iex> get_match_week_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_week_log!(Date.t()) :: MatchWeekLog.t()
  @spec get_match_week_log!(Date.t(), Teiserver.query_args()) :: MatchWeekLog.t()
  def get_match_week_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchWeekLogQueries.match_week_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_week_log.

  Returns nil if the MatchWeekLog does not exist.

  ## Examples

      iex> get_match_week_log(123)
      %MatchWeekLog{}

      iex> get_match_week_log(456)
      nil

  """
  @spec get_match_week_log(Date.t()) :: MatchWeekLog.t() | nil
  @spec get_match_week_log(Date.t(), Teiserver.query_args()) :: MatchWeekLog.t() | nil
  def get_match_week_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchWeekLogQueries.match_week_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_week_log.

  ## Examples

      iex> create_match_week_log(%{field: value})
      {:ok, %MatchWeekLog{}}

      iex> create_match_week_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_week_log(map) :: {:ok, MatchWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def create_match_week_log(attrs) do
    %MatchWeekLog{}
    |> MatchWeekLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_week_log.

  ## Examples

      iex> update_match_week_log(match_week_log, %{field: new_value})
      {:ok, %MatchWeekLog{}}

      iex> update_match_week_log(match_week_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_week_log(MatchWeekLog.t(), map) ::
          {:ok, MatchWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def update_match_week_log(%MatchWeekLog{} = match_week_log, attrs) do
    match_week_log
    |> MatchWeekLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_week_log.

  ## Examples

      iex> delete_match_week_log(match_week_log)
      {:ok, %MatchWeekLog{}}

      iex> delete_match_week_log(match_week_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_week_log(MatchWeekLog.t()) ::
          {:ok, MatchWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_week_log(%MatchWeekLog{} = match_week_log) do
    Repo.delete(match_week_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_week_log changes.

  ## Examples

      iex> change_match_week_log(match_week_log)
      %Ecto.Changeset{data: %MatchWeekLog{}}

  """
  @spec change_match_week_log(MatchWeekLog.t(), map) :: Ecto.Changeset.t()
  def change_match_week_log(%MatchWeekLog{} = match_week_log, attrs \\ %{}) do
    MatchWeekLog.changeset(match_week_log, attrs)
  end
end
