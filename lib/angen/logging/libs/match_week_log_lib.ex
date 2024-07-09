defmodule Angen.Logging.GameWeekLogLib do
  @moduledoc """
  Library of game_week_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{GameWeekLog, GameWeekLogQueries}

  @doc """
  Returns the list of game_week_logs.

  ## Examples

      iex> list_game_week_logs()
      [%GameWeekLog{}, ...]

  """
  @spec list_game_week_logs(Teiserver.query_args()) :: [GameWeekLog.t()]
  def list_game_week_logs(query_args) do
    query_args
    |> GameWeekLogQueries.game_week_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single game_week_log.

  Raises `Ecto.NoResultsError` if the GameWeekLog does not exist.

  ## Examples

      iex> get_game_week_log!(123)
      %GameWeekLog{}

      iex> get_game_week_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_game_week_log!(Date.t()) :: GameWeekLog.t()
  @spec get_game_week_log!(Date.t(), Teiserver.query_args()) :: GameWeekLog.t()
  def get_game_week_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameWeekLogQueries.game_week_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single game_week_log.

  Returns nil if the GameWeekLog does not exist.

  ## Examples

      iex> get_game_week_log(123)
      %GameWeekLog{}

      iex> get_game_week_log(456)
      nil

  """
  @spec get_game_week_log(Date.t()) :: GameWeekLog.t() | nil
  @spec get_game_week_log(Date.t(), Teiserver.query_args()) :: GameWeekLog.t() | nil
  def get_game_week_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameWeekLogQueries.game_week_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a game_week_log.

  ## Examples

      iex> create_game_week_log(%{field: value})
      {:ok, %GameWeekLog{}}

      iex> create_game_week_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_game_week_log(map) :: {:ok, GameWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def create_game_week_log(attrs) do
    %GameWeekLog{}
    |> GameWeekLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_week_log.

  ## Examples

      iex> update_game_week_log(game_week_log, %{field: new_value})
      {:ok, %GameWeekLog{}}

      iex> update_game_week_log(game_week_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_game_week_log(GameWeekLog.t(), map) ::
          {:ok, GameWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def update_game_week_log(%GameWeekLog{} = game_week_log, attrs) do
    game_week_log
    |> GameWeekLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_week_log.

  ## Examples

      iex> delete_game_week_log(game_week_log)
      {:ok, %GameWeekLog{}}

      iex> delete_game_week_log(game_week_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_game_week_log(GameWeekLog.t()) ::
          {:ok, GameWeekLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_game_week_log(%GameWeekLog{} = game_week_log) do
    Repo.delete(game_week_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_week_log changes.

  ## Examples

      iex> change_game_week_log(game_week_log)
      %Ecto.Changeset{data: %GameWeekLog{}}

  """
  @spec change_game_week_log(GameWeekLog.t(), map) :: Ecto.Changeset.t()
  def change_game_week_log(%GameWeekLog{} = game_week_log, attrs \\ %{}) do
    GameWeekLog.changeset(game_week_log, attrs)
  end
end
