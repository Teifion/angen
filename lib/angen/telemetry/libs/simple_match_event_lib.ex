defmodule Angen.Telemetry.SimpleMatchEventLib do
  @moduledoc """
  Library of simple_match_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{SimpleMatchEvent, SimpleMatchEventQueries}

  @doc """
  A wrapper around create_simple_match_event which handles grabbing the event_type_id
  """
  @spec log_simple_match_event(
          String.t(),
          Teiserver.match_id(),
          Teiserver.user_id(),
          non_neg_integer()
        ) ::
          :ok | {:error, String.t()}
  def log_simple_match_event(name, match_id, user_id, game_time_seconds) do
    type_id = Telemetry.get_or_add_event_type_id(name, "simple_match")

    attrs = %{
      event_type_id: type_id,
      match_id: match_id,
      user_id: user_id,
      inserted_at: Timex.now(),
      game_time_seconds: game_time_seconds
    }

    case create_simple_match_event(attrs) do
      {:ok, _event} ->
        :ok

      {:error, changeset} ->
        {:error,
         changeset.errors
         |> Enum.map_join(", ", fn {key, {message, _}} ->
           "#{key}: #{message}"
         end)}
    end
  end

  @doc """
  Returns the list of simple_match_events.

  ## Examples

      iex> list_simple_match_events()
      [%SimpleMatchEvent{}, ...]

  """
  @spec list_simple_match_events(Teiserver.query_args()) :: [SimpleMatchEvent.t()]
  def list_simple_match_events(query_args) do
    query_args
    |> SimpleMatchEventQueries.simple_match_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_match_event.

  Raises `Ecto.NoResultsError` if the SimpleMatchEvent does not exist.

  ## Examples

      iex> get_simple_match_event!(123)
      %SimpleMatchEvent{}

      iex> get_simple_match_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_match_event!(SimpleMatchEvent.id()) :: SimpleMatchEvent.t()
  @spec get_simple_match_event!(SimpleMatchEvent.id(), Teiserver.query_args()) ::
          SimpleMatchEvent.t()
  def get_simple_match_event!(simple_match_event_id, query_args \\ []) do
    (query_args ++ [id: simple_match_event_id])
    |> SimpleMatchEventQueries.simple_match_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_match_event.

  Returns nil if the SimpleMatchEvent does not exist.

  ## Examples

      iex> get_simple_match_event(123)
      %SimpleMatchEvent{}

      iex> get_simple_match_event(456)
      nil

  """
  @spec get_simple_match_event(SimpleMatchEvent.id()) :: SimpleMatchEvent.t() | nil
  @spec get_simple_match_event(SimpleMatchEvent.id(), Teiserver.query_args()) ::
          SimpleMatchEvent.t() | nil
  def get_simple_match_event(simple_match_event_id, query_args \\ []) do
    (query_args ++ [id: simple_match_event_id])
    |> SimpleMatchEventQueries.simple_match_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_match_event.

  ## Examples

      iex> create_simple_match_event(%{field: value})
      {:ok, %SimpleMatchEvent{}}

      iex> create_simple_match_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_match_event(map) ::
          {:ok, SimpleMatchEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_match_event(attrs) do
    %SimpleMatchEvent{}
    |> SimpleMatchEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a simple_match_event.

  ## Examples

      iex> update_simple_match_event(simple_match_event, %{field: new_value})
      {:ok, %SimpleMatchEvent{}}

      iex> update_simple_match_event(simple_match_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_match_event(SimpleMatchEvent.t(), map) ::
          {:ok, SimpleMatchEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_match_event(%SimpleMatchEvent{} = simple_match_event, attrs) do
    simple_match_event
    |> SimpleMatchEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a simple_match_event.

  ## Examples

      iex> delete_simple_match_event(simple_match_event)
      {:ok, %SimpleMatchEvent{}}

      iex> delete_simple_match_event(simple_match_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_match_event(SimpleMatchEvent.t()) ::
          {:ok, SimpleMatchEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_match_event(%SimpleMatchEvent{} = simple_match_event) do
    Repo.delete(simple_match_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_match_event changes.

  ## Examples

      iex> change_simple_match_event(simple_match_event)
      %Ecto.Changeset{data: %SimpleMatchEvent{}}

  """
  @spec change_simple_match_event(SimpleMatchEvent.t(), map) :: Ecto.Changeset.t()
  def change_simple_match_event(%SimpleMatchEvent{} = simple_match_event, attrs \\ %{}) do
    SimpleMatchEvent.changeset(simple_match_event, attrs)
  end
end
