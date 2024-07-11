defmodule Angen.Logging.GameQuarterLogLib do
  @moduledoc """
  Library of game_quarter_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{GameQuarterLog, GameQuarterLogQueries}

  @doc """
  Returns the list of game_quarter_logs.

  ## Examples

      iex> list_game_quarter_logs()
      [%GameQuarterLog{}, ...]

  """
  @spec list_game_quarter_logs(Teiserver.query_args()) :: [GameQuarterLog.t()]
  def list_game_quarter_logs(query_args) do
    query_args
    |> GameQuarterLogQueries.game_quarter_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single game_quarter_log.

  Raises `Ecto.NoResultsError` if the GameQuarterLog does not exist.

  ## Examples

      iex> get_game_quarter_log!(123)
      %GameQuarterLog{}

      iex> get_game_quarter_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_game_quarter_log!(Date.t()) :: GameQuarterLog.t()
  @spec get_game_quarter_log!(Date.t(), Teiserver.query_args()) :: GameQuarterLog.t()
  def get_game_quarter_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameQuarterLogQueries.game_quarter_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single game_quarter_log.

  Returns nil if the GameQuarterLog does not exist.

  ## Examples

      iex> get_game_quarter_log(123)
      %GameQuarterLog{}

      iex> get_game_quarter_log(456)
      nil

  """
  @spec get_game_quarter_log(Date.t()) :: GameQuarterLog.t() | nil
  @spec get_game_quarter_log(Date.t(), Teiserver.query_args()) :: GameQuarterLog.t() | nil
  def get_game_quarter_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameQuarterLogQueries.game_quarter_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last GameMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_game_quarter_log_date() :: Date.t() | nil
  def get_last_game_quarter_log_date() do
    log =
      GameQuarterLogQueries.game_quarter_log_query(
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
  Creates a game_quarter_log.

  ## Examples

      iex> create_game_quarter_log(%{field: value})
      {:ok, %GameQuarterLog{}}

      iex> create_game_quarter_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_game_quarter_log(map) ::
          {:ok, GameQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def create_game_quarter_log(attrs) do
    %GameQuarterLog{}
    |> GameQuarterLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_quarter_log.

  ## Examples

      iex> update_game_quarter_log(game_quarter_log, %{field: new_value})
      {:ok, %GameQuarterLog{}}

      iex> update_game_quarter_log(game_quarter_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_game_quarter_log(GameQuarterLog.t(), map) ::
          {:ok, GameQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def update_game_quarter_log(%GameQuarterLog{} = game_quarter_log, attrs) do
    game_quarter_log
    |> GameQuarterLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_quarter_log.

  ## Examples

      iex> delete_game_quarter_log(game_quarter_log)
      {:ok, %GameQuarterLog{}}

      iex> delete_game_quarter_log(game_quarter_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_game_quarter_log(GameQuarterLog.t()) ::
          {:ok, GameQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_game_quarter_log(%GameQuarterLog{} = game_quarter_log) do
    Repo.delete(game_quarter_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_quarter_log changes.

  ## Examples

      iex> change_game_quarter_log(game_quarter_log)
      %Ecto.Changeset{data: %GameQuarterLog{}}

  """
  @spec change_game_quarter_log(GameQuarterLog.t(), map) :: Ecto.Changeset.t()
  def change_game_quarter_log(%GameQuarterLog{} = game_quarter_log, attrs \\ %{}) do
    GameQuarterLog.changeset(game_quarter_log, attrs)
  end
end
