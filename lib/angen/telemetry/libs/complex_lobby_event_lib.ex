defmodule Angen.Telemetry.ComplexLobbyEventLib do
  @moduledoc """
  Library of complex_lobby_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{ComplexLobbyEvent, ComplexLobbyEventQueries}

  @doc """
  A wrapper around create_complex_lobby_event which handles grabbing the event_type_id
  """
  @spec log_complex_lobby_event(String.t(), Teiserver.match_id(), Teiserver.user_id(), map()) ::
          :ok | {:error, String.t()}
  def log_complex_lobby_event(name, match_id, user_id \\ nil, %{} = details) do
    type_id = Telemetry.get_or_add_event_type_id(name, "complex_lobby")

    attrs = %{
      event_type_id: type_id,
      match_id: match_id,
      user_id: user_id,
      inserted_at: DateTime.utc_now(),
      details: details
    }

    case create_complex_lobby_event(attrs) do
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
  Returns the list of complex_lobby_events.

  ## Examples

      iex> list_complex_lobby_events()
      [%ComplexLobbyEvent{}, ...]

  """
  @spec list_complex_lobby_events(Teiserver.query_args()) :: [ComplexLobbyEvent.t()]
  def list_complex_lobby_events(query_args) do
    query_args
    |> ComplexLobbyEventQueries.complex_lobby_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single complex_lobby_event.

  Raises `Ecto.NoResultsError` if the ComplexLobbyEvent does not exist.

  ## Examples

      iex> get_complex_lobby_event!(123)
      %ComplexLobbyEvent{}

      iex> get_complex_lobby_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_complex_lobby_event!(ComplexLobbyEvent.id()) :: ComplexLobbyEvent.t()
  @spec get_complex_lobby_event!(ComplexLobbyEvent.id(), Teiserver.query_args()) ::
          ComplexLobbyEvent.t()
  def get_complex_lobby_event!(complex_lobby_event_id, query_args \\ []) do
    (query_args ++ [id: complex_lobby_event_id])
    |> ComplexLobbyEventQueries.complex_lobby_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single complex_lobby_event.

  Returns nil if the ComplexLobbyEvent does not exist.

  ## Examples

      iex> get_complex_lobby_event(123)
      %ComplexLobbyEvent{}

      iex> get_complex_lobby_event(456)
      nil

  """
  @spec get_complex_lobby_event(ComplexLobbyEvent.id()) :: ComplexLobbyEvent.t() | nil
  @spec get_complex_lobby_event(ComplexLobbyEvent.id(), Teiserver.query_args()) ::
          ComplexLobbyEvent.t() | nil
  def get_complex_lobby_event(complex_lobby_event_id, query_args \\ []) do
    (query_args ++ [id: complex_lobby_event_id])
    |> ComplexLobbyEventQueries.complex_lobby_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a complex_lobby_event.

  ## Examples

      iex> create_complex_lobby_event(%{field: value})
      {:ok, %ComplexLobbyEvent{}}

      iex> create_complex_lobby_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_complex_lobby_event(map) ::
          {:ok, ComplexLobbyEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_complex_lobby_event(attrs) do
    %ComplexLobbyEvent{}
    |> ComplexLobbyEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complex_lobby_event.

  ## Examples

      iex> update_complex_lobby_event(complex_lobby_event, %{field: new_value})
      {:ok, %ComplexLobbyEvent{}}

      iex> update_complex_lobby_event(complex_lobby_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_complex_lobby_event(ComplexLobbyEvent.t(), map) ::
          {:ok, ComplexLobbyEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_complex_lobby_event(%ComplexLobbyEvent{} = complex_lobby_event, attrs) do
    complex_lobby_event
    |> ComplexLobbyEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complex_lobby_event.

  ## Examples

      iex> delete_complex_lobby_event(complex_lobby_event)
      {:ok, %ComplexLobbyEvent{}}

      iex> delete_complex_lobby_event(complex_lobby_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_complex_lobby_event(ComplexLobbyEvent.t()) ::
          {:ok, ComplexLobbyEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_complex_lobby_event(%ComplexLobbyEvent{} = complex_lobby_event) do
    Repo.delete(complex_lobby_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complex_lobby_event changes.

  ## Examples

      iex> change_complex_lobby_event(complex_lobby_event)
      %Ecto.Changeset{data: %ComplexLobbyEvent{}}

  """
  @spec change_complex_lobby_event(ComplexLobbyEvent.t(), map) :: Ecto.Changeset.t()
  def change_complex_lobby_event(%ComplexLobbyEvent{} = complex_lobby_event, attrs \\ %{}) do
    ComplexLobbyEvent.changeset(complex_lobby_event, attrs)
  end
end
