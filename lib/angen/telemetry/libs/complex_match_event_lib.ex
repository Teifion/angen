defmodule Angen.Telemetry.ComplexMatchEventLib do
  @moduledoc """
  Library of complex_match_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{ComplexMatchEvent, ComplexMatchEventQueries}

  @doc """
  A wrapper around create_complex_match_event which handles grabbing the event_type_id
  """
  @spec log_complex_match_event(String.t(), Teiserver.match_id(), Teiserver.user_id(), non_neg_integer(), map()) ::
          :ok | {:error, String.t()}
  def log_complex_match_event(name, match_id, user_id, game_time_seconds, details) do
    type_id = Telemetry.get_or_add_event_type_id(name, "complex_match")

    attrs = %{
      event_type_id: type_id,
      match_id: match_id,
      user_id: user_id,
      inserted_at: Timex.now(),
      game_time_seconds: game_time_seconds,
      details: details
    }

    case create_complex_match_event(attrs) do
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
  Returns the list of complex_match_events.

  ## Examples

      iex> list_complex_match_events()
      [%ComplexMatchEvent{}, ...]

  """
  @spec list_complex_match_events(Teiserver.query_args()) :: [ComplexMatchEvent.t()]
  def list_complex_match_events(query_args) do
    query_args
    |> ComplexMatchEventQueries.complex_match_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single complex_match_event.

  Raises `Ecto.NoResultsError` if the ComplexMatchEvent does not exist.

  ## Examples

      iex> get_complex_match_event!(123)
      %ComplexMatchEvent{}

      iex> get_complex_match_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_complex_match_event!(ComplexMatchEvent.id()) :: ComplexMatchEvent.t()
  @spec get_complex_match_event!(ComplexMatchEvent.id(), Teiserver.query_args()) ::
          ComplexMatchEvent.t()
  def get_complex_match_event!(complex_match_event_id, query_args \\ []) do
    (query_args ++ [id: complex_match_event_id])
    |> ComplexMatchEventQueries.complex_match_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single complex_match_event.

  Returns nil if the ComplexMatchEvent does not exist.

  ## Examples

      iex> get_complex_match_event(123)
      %ComplexMatchEvent{}

      iex> get_complex_match_event(456)
      nil

  """
  @spec get_complex_match_event(ComplexMatchEvent.id()) :: ComplexMatchEvent.t() | nil
  @spec get_complex_match_event(ComplexMatchEvent.id(), Teiserver.query_args()) ::
          ComplexMatchEvent.t() | nil
  def get_complex_match_event(complex_match_event_id, query_args \\ []) do
    (query_args ++ [id: complex_match_event_id])
    |> ComplexMatchEventQueries.complex_match_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a complex_match_event.

  ## Examples

      iex> create_complex_match_event(%{field: value})
      {:ok, %ComplexMatchEvent{}}

      iex> create_complex_match_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_complex_match_event(map) ::
          {:ok, ComplexMatchEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_complex_match_event(attrs) do
    %ComplexMatchEvent{}
    |> ComplexMatchEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complex_match_event.

  ## Examples

      iex> update_complex_match_event(complex_match_event, %{field: new_value})
      {:ok, %ComplexMatchEvent{}}

      iex> update_complex_match_event(complex_match_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_complex_match_event(ComplexMatchEvent.t(), map) ::
          {:ok, ComplexMatchEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_complex_match_event(%ComplexMatchEvent{} = complex_match_event, attrs) do
    complex_match_event
    |> ComplexMatchEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complex_match_event.

  ## Examples

      iex> delete_complex_match_event(complex_match_event)
      {:ok, %ComplexMatchEvent{}}

      iex> delete_complex_match_event(complex_match_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_complex_match_event(ComplexMatchEvent.t()) ::
          {:ok, ComplexMatchEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_complex_match_event(%ComplexMatchEvent{} = complex_match_event) do
    Repo.delete(complex_match_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complex_match_event changes.

  ## Examples

      iex> change_complex_match_event(complex_match_event)
      %Ecto.Changeset{data: %ComplexMatchEvent{}}

  """
  @spec change_complex_match_event(ComplexMatchEvent.t(), map) :: Ecto.Changeset.t()
  def change_complex_match_event(%ComplexMatchEvent{} = complex_match_event, attrs \\ %{}) do
    ComplexMatchEvent.changeset(complex_match_event, attrs)
  end
end
