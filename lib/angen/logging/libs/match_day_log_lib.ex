defmodule Angen.Logging.GameDayLogLib do
  @moduledoc """
  Library of game_day_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{GameDayLog, GameDayLogQueries}

  @doc """
  Returns the list of game_day_logs.

  ## Examples

      iex> list_game_day_logs()
      [%GameDayLog{}, ...]

  """
  @spec list_game_day_logs(Teiserver.query_args()) :: [GameDayLog.t()]
  def list_game_day_logs(query_args) do
    query_args
    |> GameDayLogQueries.game_day_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single game_day_log.

  Raises `Ecto.NoResultsError` if the GameDayLog does not exist.

  ## Examples

      iex> get_game_day_log!(123)
      %GameDayLog{}

      iex> get_game_day_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_game_day_log!(Date.t()) :: GameDayLog.t()
  @spec get_game_day_log!(Date.t(), Teiserver.query_args()) :: GameDayLog.t()
  def get_game_day_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameDayLogQueries.game_day_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single game_day_log.

  Returns nil if the GameDayLog does not exist.

  ## Examples

      iex> get_game_day_log(123)
      %GameDayLog{}

      iex> get_game_day_log(456)
      nil

  """
  @spec get_game_day_log(Date.t()) :: GameDayLog.t() | nil
  @spec get_game_day_log(Date.t(), Teiserver.query_args()) :: GameDayLog.t() | nil
  def get_game_day_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameDayLogQueries.game_day_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a game_day_log.

  ## Examples

      iex> create_game_day_log(%{field: value})
      {:ok, %GameDayLog{}}

      iex> create_game_day_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_game_day_log(map) :: {:ok, GameDayLog.t()} | {:error, Ecto.Changeset.t()}
  def create_game_day_log(attrs) do
    %GameDayLog{}
    |> GameDayLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_day_log.

  ## Examples

      iex> update_game_day_log(game_day_log, %{field: new_value})
      {:ok, %GameDayLog{}}

      iex> update_game_day_log(game_day_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_game_day_log(GameDayLog.t(), map) ::
          {:ok, GameDayLog.t()} | {:error, Ecto.Changeset.t()}
  def update_game_day_log(%GameDayLog{} = game_day_log, attrs) do
    game_day_log
    |> GameDayLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_day_log.

  ## Examples

      iex> delete_game_day_log(game_day_log)
      {:ok, %GameDayLog{}}

      iex> delete_game_day_log(game_day_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_game_day_log(GameDayLog.t()) ::
          {:ok, GameDayLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_game_day_log(%GameDayLog{} = game_day_log) do
    Repo.delete(game_day_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_day_log changes.

  ## Examples

      iex> change_game_day_log(game_day_log)
      %Ecto.Changeset{data: %GameDayLog{}}

  """
  @spec change_game_day_log(GameDayLog.t(), map) :: Ecto.Changeset.t()
  def change_game_day_log(%GameDayLog{} = game_day_log, attrs \\ %{}) do
    GameDayLog.changeset(game_day_log, attrs)
  end
end
