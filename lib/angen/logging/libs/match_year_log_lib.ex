defmodule Angen.Logging.MatchYearLogLib do
  @moduledoc """
  Library of match_year_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{MatchYearLog, MatchYearLogQueries}

  @doc """
  Returns the list of match_year_logs.

  ## Examples

      iex> list_match_year_logs()
      [%MatchYearLog{}, ...]

  """
  @spec list_match_year_logs(Teiserver.query_args()) :: [MatchYearLog.t()]
  def list_match_year_logs(query_args) do
    query_args
    |> MatchYearLogQueries.match_year_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_year_log.

  Raises `Ecto.NoResultsError` if the MatchYearLog does not exist.

  ## Examples

      iex> get_match_year_log!(123)
      %MatchYearLog{}

      iex> get_match_year_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_year_log!(Date.t()) :: MatchYearLog.t()
  @spec get_match_year_log!(Date.t(), Teiserver.query_args()) :: MatchYearLog.t()
  def get_match_year_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchYearLogQueries.match_year_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_year_log.

  Returns nil if the MatchYearLog does not exist.

  ## Examples

      iex> get_match_year_log(123)
      %MatchYearLog{}

      iex> get_match_year_log(456)
      nil

  """
  @spec get_match_year_log(Date.t()) :: MatchYearLog.t() | nil
  @spec get_match_year_log(Date.t(), Teiserver.query_args()) :: MatchYearLog.t() | nil
  def get_match_year_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchYearLogQueries.match_year_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_year_log.

  ## Examples

      iex> create_match_year_log(%{field: value})
      {:ok, %MatchYearLog{}}

      iex> create_match_year_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_year_log(map) :: {:ok, MatchYearLog.t()} | {:error, Ecto.Changeset.t()}
  def create_match_year_log(attrs) do
    %MatchYearLog{}
    |> MatchYearLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_year_log.

  ## Examples

      iex> update_match_year_log(match_year_log, %{field: new_value})
      {:ok, %MatchYearLog{}}

      iex> update_match_year_log(match_year_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_year_log(MatchYearLog.t(), map) ::
          {:ok, MatchYearLog.t()} | {:error, Ecto.Changeset.t()}
  def update_match_year_log(%MatchYearLog{} = match_year_log, attrs) do
    match_year_log
    |> MatchYearLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_year_log.

  ## Examples

      iex> delete_match_year_log(match_year_log)
      {:ok, %MatchYearLog{}}

      iex> delete_match_year_log(match_year_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_year_log(MatchYearLog.t()) ::
          {:ok, MatchYearLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_year_log(%MatchYearLog{} = match_year_log) do
    Repo.delete(match_year_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_year_log changes.

  ## Examples

      iex> change_match_year_log(match_year_log)
      %Ecto.Changeset{data: %MatchYearLog{}}

  """
  @spec change_match_year_log(MatchYearLog.t(), map) :: Ecto.Changeset.t()
  def change_match_year_log(%MatchYearLog{} = match_year_log, attrs \\ %{}) do
    MatchYearLog.changeset(match_year_log, attrs)
  end
end
