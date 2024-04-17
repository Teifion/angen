defmodule Angen.Logging.MatchQuarterLogLib do
  @moduledoc """
  Library of match_quarter_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{MatchQuarterLog, MatchQuarterLogQueries}

  @doc """
  Returns the list of match_quarter_logs.

  ## Examples

      iex> list_match_quarter_logs()
      [%MatchQuarterLog{}, ...]

  """
  @spec list_match_quarter_logs(Teiserver.query_args()) :: [MatchQuarterLog.t()]
  def list_match_quarter_logs(query_args) do
    query_args
    |> MatchQuarterLogQueries.match_quarter_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_quarter_log.

  Raises `Ecto.NoResultsError` if the MatchQuarterLog does not exist.

  ## Examples

      iex> get_match_quarter_log!(123)
      %MatchQuarterLog{}

      iex> get_match_quarter_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_quarter_log!(Date.t()) :: MatchQuarterLog.t()
  @spec get_match_quarter_log!(Date.t(), Teiserver.query_args()) :: MatchQuarterLog.t()
  def get_match_quarter_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchQuarterLogQueries.match_quarter_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_quarter_log.

  Returns nil if the MatchQuarterLog does not exist.

  ## Examples

      iex> get_match_quarter_log(123)
      %MatchQuarterLog{}

      iex> get_match_quarter_log(456)
      nil

  """
  @spec get_match_quarter_log(Date.t()) :: MatchQuarterLog.t() | nil
  @spec get_match_quarter_log(Date.t(), Teiserver.query_args()) :: MatchQuarterLog.t() | nil
  def get_match_quarter_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchQuarterLogQueries.match_quarter_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_quarter_log.

  ## Examples

      iex> create_match_quarter_log(%{field: value})
      {:ok, %MatchQuarterLog{}}

      iex> create_match_quarter_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_quarter_log(map) :: {:ok, MatchQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def create_match_quarter_log(attrs) do
    %MatchQuarterLog{}
    |> MatchQuarterLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_quarter_log.

  ## Examples

      iex> update_match_quarter_log(match_quarter_log, %{field: new_value})
      {:ok, %MatchQuarterLog{}}

      iex> update_match_quarter_log(match_quarter_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_quarter_log(MatchQuarterLog.t(), map) ::
          {:ok, MatchQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def update_match_quarter_log(%MatchQuarterLog{} = match_quarter_log, attrs) do
    match_quarter_log
    |> MatchQuarterLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_quarter_log.

  ## Examples

      iex> delete_match_quarter_log(match_quarter_log)
      {:ok, %MatchQuarterLog{}}

      iex> delete_match_quarter_log(match_quarter_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_quarter_log(MatchQuarterLog.t()) ::
          {:ok, MatchQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_quarter_log(%MatchQuarterLog{} = match_quarter_log) do
    Repo.delete(match_quarter_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_quarter_log changes.

  ## Examples

      iex> change_match_quarter_log(match_quarter_log)
      %Ecto.Changeset{data: %MatchQuarterLog{}}

  """
  @spec change_match_quarter_log(MatchQuarterLog.t(), map) :: Ecto.Changeset.t()
  def change_match_quarter_log(%MatchQuarterLog{} = match_quarter_log, attrs \\ %{}) do
    MatchQuarterLog.changeset(match_quarter_log, attrs)
  end
end
