defmodule Angen.Logging.MatchMonthLogLib do
  @moduledoc """
  Library of match_month_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{MatchMonthLog, MatchMonthLogQueries}

  @doc """
  Returns the list of match_month_logs.

  ## Examples

      iex> list_match_month_logs()
      [%MatchMonthLog{}, ...]

  """
  @spec list_match_month_logs(Teiserver.query_args()) :: [MatchMonthLog.t()]
  def list_match_month_logs(query_args) do
    query_args
    |> MatchMonthLogQueries.match_month_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_month_log.

  Raises `Ecto.NoResultsError` if the MatchMonthLog does not exist.

  ## Examples

      iex> get_match_month_log!(123)
      %MatchMonthLog{}

      iex> get_match_month_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_month_log!(Date.t()) :: MatchMonthLog.t()
  @spec get_match_month_log!(Date.t(), Teiserver.query_args()) :: MatchMonthLog.t()
  def get_match_month_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchMonthLogQueries.match_month_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_month_log.

  Returns nil if the MatchMonthLog does not exist.

  ## Examples

      iex> get_match_month_log(123)
      %MatchMonthLog{}

      iex> get_match_month_log(456)
      nil

  """
  @spec get_match_month_log(Date.t()) :: MatchMonthLog.t() | nil
  @spec get_match_month_log(Date.t(), Teiserver.query_args()) :: MatchMonthLog.t() | nil
  def get_match_month_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> MatchMonthLogQueries.match_month_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_month_log.

  ## Examples

      iex> create_match_month_log(%{field: value})
      {:ok, %MatchMonthLog{}}

      iex> create_match_month_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_month_log(map) :: {:ok, MatchMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def create_match_month_log(attrs) do
    %MatchMonthLog{}
    |> MatchMonthLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_month_log.

  ## Examples

      iex> update_match_month_log(match_month_log, %{field: new_value})
      {:ok, %MatchMonthLog{}}

      iex> update_match_month_log(match_month_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_month_log(MatchMonthLog.t(), map) ::
          {:ok, MatchMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def update_match_month_log(%MatchMonthLog{} = match_month_log, attrs) do
    match_month_log
    |> MatchMonthLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_month_log.

  ## Examples

      iex> delete_match_month_log(match_month_log)
      {:ok, %MatchMonthLog{}}

      iex> delete_match_month_log(match_month_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_month_log(MatchMonthLog.t()) ::
          {:ok, MatchMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_month_log(%MatchMonthLog{} = match_month_log) do
    Repo.delete(match_month_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_month_log changes.

  ## Examples

      iex> change_match_month_log(match_month_log)
      %Ecto.Changeset{data: %MatchMonthLog{}}

  """
  @spec change_match_month_log(MatchMonthLog.t(), map) :: Ecto.Changeset.t()
  def change_match_month_log(%MatchMonthLog{} = match_month_log, attrs \\ %{}) do
    MatchMonthLog.changeset(match_month_log, attrs)
  end
end
