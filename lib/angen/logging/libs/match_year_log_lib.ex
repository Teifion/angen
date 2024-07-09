defmodule Angen.Logging.GameYearLogLib do
  @moduledoc """
  Library of game_year_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{GameYearLog, GameYearLogQueries}

  @doc """
  Returns the list of game_year_logs.

  ## Examples

      iex> list_game_year_logs()
      [%GameYearLog{}, ...]

  """
  @spec list_game_year_logs(Teiserver.query_args()) :: [GameYearLog.t()]
  def list_game_year_logs(query_args) do
    query_args
    |> GameYearLogQueries.game_year_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single game_year_log.

  Raises `Ecto.NoResultsError` if the GameYearLog does not exist.

  ## Examples

      iex> get_game_year_log!(123)
      %GameYearLog{}

      iex> get_game_year_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_game_year_log!(Date.t()) :: GameYearLog.t()
  @spec get_game_year_log!(Date.t(), Teiserver.query_args()) :: GameYearLog.t()
  def get_game_year_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameYearLogQueries.game_year_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single game_year_log.

  Returns nil if the GameYearLog does not exist.

  ## Examples

      iex> get_game_year_log(123)
      %GameYearLog{}

      iex> get_game_year_log(456)
      nil

  """
  @spec get_game_year_log(Date.t()) :: GameYearLog.t() | nil
  @spec get_game_year_log(Date.t(), Teiserver.query_args()) :: GameYearLog.t() | nil
  def get_game_year_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameYearLogQueries.game_year_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a game_year_log.

  ## Examples

      iex> create_game_year_log(%{field: value})
      {:ok, %GameYearLog{}}

      iex> create_game_year_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_game_year_log(map) :: {:ok, GameYearLog.t()} | {:error, Ecto.Changeset.t()}
  def create_game_year_log(attrs) do
    %GameYearLog{}
    |> GameYearLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_year_log.

  ## Examples

      iex> update_game_year_log(game_year_log, %{field: new_value})
      {:ok, %GameYearLog{}}

      iex> update_game_year_log(game_year_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_game_year_log(GameYearLog.t(), map) ::
          {:ok, GameYearLog.t()} | {:error, Ecto.Changeset.t()}
  def update_game_year_log(%GameYearLog{} = game_year_log, attrs) do
    game_year_log
    |> GameYearLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_year_log.

  ## Examples

      iex> delete_game_year_log(game_year_log)
      {:ok, %GameYearLog{}}

      iex> delete_game_year_log(game_year_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_game_year_log(GameYearLog.t()) ::
          {:ok, GameYearLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_game_year_log(%GameYearLog{} = game_year_log) do
    Repo.delete(game_year_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_year_log changes.

  ## Examples

      iex> change_game_year_log(game_year_log)
      %Ecto.Changeset{data: %GameYearLog{}}

  """
  @spec change_game_year_log(GameYearLog.t(), map) :: Ecto.Changeset.t()
  def change_game_year_log(%GameYearLog{} = game_year_log, attrs \\ %{}) do
    GameYearLog.changeset(game_year_log, attrs)
  end
end
