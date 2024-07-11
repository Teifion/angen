defmodule Angen.Logging.GameMonthLogLib do
  @moduledoc """
  Library of game_month_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{GameMonthLog, GameMonthLogQueries}

  @doc """
  Returns the list of game_month_logs.

  ## Examples

      iex> list_game_month_logs()
      [%GameMonthLog{}, ...]

  """
  @spec list_game_month_logs(Teiserver.query_args()) :: [GameMonthLog.t()]
  def list_game_month_logs(query_args) do
    query_args
    |> GameMonthLogQueries.game_month_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single game_month_log.

  Raises `Ecto.NoResultsError` if the GameMonthLog does not exist.

  ## Examples

      iex> get_game_month_log!(123)
      %GameMonthLog{}

      iex> get_game_month_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_game_month_log!(Date.t()) :: GameMonthLog.t()
  @spec get_game_month_log!(Date.t(), Teiserver.query_args()) :: GameMonthLog.t()
  def get_game_month_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameMonthLogQueries.game_month_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single game_month_log.

  Returns nil if the GameMonthLog does not exist.

  ## Examples

      iex> get_game_month_log(123)
      %GameMonthLog{}

      iex> get_game_month_log(456)
      nil

  """
  @spec get_game_month_log(Date.t()) :: GameMonthLog.t() | nil
  @spec get_game_month_log(Date.t(), Teiserver.query_args()) :: GameMonthLog.t() | nil
  def get_game_month_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> GameMonthLogQueries.game_month_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last GameMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_game_month_log_date() :: Date.t() | nil
  def get_last_game_month_log_date() do
    log =
      GameMonthLogQueries.game_month_log_query(
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
  Creates a game_month_log.

  ## Examples

      iex> create_game_month_log(%{field: value})
      {:ok, %GameMonthLog{}}

      iex> create_game_month_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_game_month_log(map) :: {:ok, GameMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def create_game_month_log(attrs) do
    %GameMonthLog{}
    |> GameMonthLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_month_log.

  ## Examples

      iex> update_game_month_log(game_month_log, %{field: new_value})
      {:ok, %GameMonthLog{}}

      iex> update_game_month_log(game_month_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_game_month_log(GameMonthLog.t(), map) ::
          {:ok, GameMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def update_game_month_log(%GameMonthLog{} = game_month_log, attrs) do
    game_month_log
    |> GameMonthLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_month_log.

  ## Examples

      iex> delete_game_month_log(game_month_log)
      {:ok, %GameMonthLog{}}

      iex> delete_game_month_log(game_month_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_game_month_log(GameMonthLog.t()) ::
          {:ok, GameMonthLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_game_month_log(%GameMonthLog{} = game_month_log) do
    Repo.delete(game_month_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_month_log changes.

  ## Examples

      iex> change_game_month_log(game_month_log)
      %Ecto.Changeset{data: %GameMonthLog{}}

  """
  @spec change_game_month_log(GameMonthLog.t(), map) :: Ecto.Changeset.t()
  def change_game_month_log(%GameMonthLog{} = game_month_log, attrs \\ %{}) do
    GameMonthLog.changeset(game_month_log, attrs)
  end
end
