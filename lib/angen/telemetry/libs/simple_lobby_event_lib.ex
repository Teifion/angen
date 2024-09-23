defmodule Angen.Telemetry.SimpleLobbyEventLib do
  @moduledoc """
  Library of simple_lobby_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{SimpleLobbyEvent, SimpleLobbyEventQueries}

  @doc """
  A wrapper around create_simple_lobby_event which handles grabbing the event_type_id
  """
  @spec log_simple_lobby_event(String.t(), Teiserver.match_id(), Teiserver.user_id()) ::
          :ok | {:error, String.t()}
  def log_simple_lobby_event(name, match_id, user_id \\ nil) do
    type_id = Telemetry.get_or_add_event_type_id(name, "simple_lobby")

    attrs = %{
      event_type_id: type_id,
      match_id: match_id,
      user_id: user_id,
      inserted_at: DateTime.utc_now()
    }

    case create_simple_lobby_event(attrs) do
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
  Returns the list of simple_lobby_events.

  ## Examples

      iex> list_simple_lobby_events()
      [%SimpleLobbyEvent{}, ...]

  """
  @spec list_simple_lobby_events(Teiserver.query_args()) :: [SimpleLobbyEvent.t()]
  def list_simple_lobby_events(query_args) do
    query_args
    |> SimpleLobbyEventQueries.simple_lobby_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_lobby_event.

  Raises `Ecto.NoResultsError` if the SimpleLobbyEvent does not exist.

  ## Examples

      iex> get_simple_lobby_event!(123)
      %SimpleLobbyEvent{}

      iex> get_simple_lobby_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_lobby_event!(SimpleLobbyEvent.id()) :: SimpleLobbyEvent.t()
  @spec get_simple_lobby_event!(SimpleLobbyEvent.id(), Teiserver.query_args()) ::
          SimpleLobbyEvent.t()
  def get_simple_lobby_event!(simple_lobby_event_id, query_args \\ []) do
    (query_args ++ [id: simple_lobby_event_id])
    |> SimpleLobbyEventQueries.simple_lobby_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_lobby_event.

  Returns nil if the SimpleLobbyEvent does not exist.

  ## Examples

      iex> get_simple_lobby_event(123)
      %SimpleLobbyEvent{}

      iex> get_simple_lobby_event(456)
      nil

  """
  @spec get_simple_lobby_event(SimpleLobbyEvent.id()) :: SimpleLobbyEvent.t() | nil
  @spec get_simple_lobby_event(SimpleLobbyEvent.id(), Teiserver.query_args()) ::
          SimpleLobbyEvent.t() | nil
  def get_simple_lobby_event(simple_lobby_event_id, query_args \\ []) do
    (query_args ++ [id: simple_lobby_event_id])
    |> SimpleLobbyEventQueries.simple_lobby_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_lobby_event.

  ## Examples

      iex> create_simple_lobby_event(%{field: value})
      {:ok, %SimpleLobbyEvent{}}

      iex> create_simple_lobby_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_lobby_event(map) ::
          {:ok, SimpleLobbyEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_lobby_event(attrs) do
    %SimpleLobbyEvent{}
    |> SimpleLobbyEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a simple_lobby_event.

  ## Examples

      iex> update_simple_lobby_event(simple_lobby_event, %{field: new_value})
      {:ok, %SimpleLobbyEvent{}}

      iex> update_simple_lobby_event(simple_lobby_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_lobby_event(SimpleLobbyEvent.t(), map) ::
          {:ok, SimpleLobbyEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_lobby_event(%SimpleLobbyEvent{} = simple_lobby_event, attrs) do
    simple_lobby_event
    |> SimpleLobbyEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a simple_lobby_event.

  ## Examples

      iex> delete_simple_lobby_event(simple_lobby_event)
      {:ok, %SimpleLobbyEvent{}}

      iex> delete_simple_lobby_event(simple_lobby_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_lobby_event(SimpleLobbyEvent.t()) ::
          {:ok, SimpleLobbyEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_lobby_event(%SimpleLobbyEvent{} = simple_lobby_event) do
    Repo.delete(simple_lobby_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_lobby_event changes.

  ## Examples

      iex> change_simple_lobby_event(simple_lobby_event)
      %Ecto.Changeset{data: %SimpleLobbyEvent{}}

  """
  @spec change_simple_lobby_event(SimpleLobbyEvent.t(), map) :: Ecto.Changeset.t()
  def change_simple_lobby_event(%SimpleLobbyEvent{} = simple_lobby_event, attrs \\ %{}) do
    SimpleLobbyEvent.changeset(simple_lobby_event, attrs)
  end
end
