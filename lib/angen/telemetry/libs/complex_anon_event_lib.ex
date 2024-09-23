defmodule Angen.Telemetry.ComplexAnonEventLib do
  @moduledoc """
  Library of complex_anon_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{ComplexAnonEvent, ComplexAnonEventQueries}

  @doc """
  A wrapper around create_complex_anon_event which handles grabbing the event_type_id
  """
  @spec log_complex_anon_event(String.t(), Ecto.UUID.t(), map()) :: :ok | {:error, String.t()}
  def log_complex_anon_event(name, hash_id, details) do
    type_id = Telemetry.get_or_add_event_type_id(name, "complex_anon")

    attrs = %{
      event_type_id: type_id,
      hash_id: hash_id,
      inserted_at: DateTime.utc_now(),
      details: details
    }

    case create_complex_anon_event(attrs) do
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
  Returns the list of complex_anon_events.

  ## Examples

      iex> list_complex_anon_events()
      [%ComplexAnonEvent{}, ...]

  """
  @spec list_complex_anon_events(Teiserver.query_args()) :: [ComplexAnonEvent.t()]
  def list_complex_anon_events(query_args) do
    query_args
    |> ComplexAnonEventQueries.complex_anon_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single complex_anon_event.

  Raises `Ecto.NoResultsError` if the ComplexAnonEvent does not exist.

  ## Examples

      iex> get_complex_anon_event!(123)
      %ComplexAnonEvent{}

      iex> get_complex_anon_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_complex_anon_event!(ComplexAnonEvent.id()) :: ComplexAnonEvent.t()
  @spec get_complex_anon_event!(ComplexAnonEvent.id(), Teiserver.query_args()) ::
          ComplexAnonEvent.t()
  def get_complex_anon_event!(complex_anon_event_id, query_args \\ []) do
    (query_args ++ [id: complex_anon_event_id])
    |> ComplexAnonEventQueries.complex_anon_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single complex_anon_event.

  Returns nil if the ComplexAnonEvent does not exist.

  ## Examples

      iex> get_complex_anon_event(123)
      %ComplexAnonEvent{}

      iex> get_complex_anon_event(456)
      nil

  """
  @spec get_complex_anon_event(ComplexAnonEvent.id()) :: ComplexAnonEvent.t() | nil
  @spec get_complex_anon_event(ComplexAnonEvent.id(), Teiserver.query_args()) ::
          ComplexAnonEvent.t() | nil
  def get_complex_anon_event(complex_anon_event_id, query_args \\ []) do
    (query_args ++ [id: complex_anon_event_id])
    |> ComplexAnonEventQueries.complex_anon_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a complex_anon_event.

  ## Examples

      iex> create_complex_anon_event(%{field: value})
      {:ok, %ComplexAnonEvent{}}

      iex> create_complex_anon_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_complex_anon_event(map) ::
          {:ok, ComplexAnonEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_complex_anon_event(attrs) do
    %ComplexAnonEvent{}
    |> ComplexAnonEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complex_anon_event.

  ## Examples

      iex> update_complex_anon_event(complex_anon_event, %{field: new_value})
      {:ok, %ComplexAnonEvent{}}

      iex> update_complex_anon_event(complex_anon_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_complex_anon_event(ComplexAnonEvent.t(), map) ::
          {:ok, ComplexAnonEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_complex_anon_event(%ComplexAnonEvent{} = complex_anon_event, attrs) do
    complex_anon_event
    |> ComplexAnonEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complex_anon_event.

  ## Examples

      iex> delete_complex_anon_event(complex_anon_event)
      {:ok, %ComplexAnonEvent{}}

      iex> delete_complex_anon_event(complex_anon_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_complex_anon_event(ComplexAnonEvent.t()) ::
          {:ok, ComplexAnonEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_complex_anon_event(%ComplexAnonEvent{} = complex_anon_event) do
    Repo.delete(complex_anon_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complex_anon_event changes.

  ## Examples

      iex> change_complex_anon_event(complex_anon_event)
      %Ecto.Changeset{data: %ComplexAnonEvent{}}

  """
  @spec change_complex_anon_event(ComplexAnonEvent.t(), map) :: Ecto.Changeset.t()
  def change_complex_anon_event(
        %ComplexAnonEvent{} = complex_anon_event,
        attrs \\ %{}
      ) do
    ComplexAnonEvent.changeset(complex_anon_event, attrs)
  end
end
