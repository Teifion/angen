defmodule Angen.Telemetry.ComplexClientappEventLib do
  @moduledoc """
  Library of complex_clientapp_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{ComplexClientappEvent, ComplexClientappEventQueries}

  @doc """
  A wrapper around create_complex_clientapp_event which handles grabbing the event_type_id
  """
  @spec log_complex_clientapp_event(String.t(), Teiserver.user_id(), map()) ::
          :ok | {:error, String.t()}
  def log_complex_clientapp_event(name, user_id, details) do
    type_id = Telemetry.get_or_add_event_type_id(name, "complex_clientapp")

    attrs = %{
      event_type_id: type_id,
      user_id: user_id,
      inserted_at: DateTime.utc_now(),
      details: details
    }

    case create_complex_clientapp_event(attrs) do
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
  Returns the list of complex_clientapp_events.

  ## Examples

      iex> list_complex_clientapp_events()
      [%ComplexClientappEvent{}, ...]

  """
  @spec list_complex_clientapp_events(Teiserver.query_args()) :: [ComplexClientappEvent.t()]
  def list_complex_clientapp_events(query_args) do
    query_args
    |> ComplexClientappEventQueries.complex_clientapp_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single complex_clientapp_event.

  Raises `Ecto.NoResultsError` if the ComplexClientappEvent does not exist.

  ## Examples

      iex> get_complex_clientapp_event!(123)
      %ComplexClientappEvent{}

      iex> get_complex_clientapp_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_complex_clientapp_event!(ComplexClientappEvent.id()) :: ComplexClientappEvent.t()
  @spec get_complex_clientapp_event!(ComplexClientappEvent.id(), Teiserver.query_args()) ::
          ComplexClientappEvent.t()
  def get_complex_clientapp_event!(complex_clientapp_event_id, query_args \\ []) do
    (query_args ++ [id: complex_clientapp_event_id])
    |> ComplexClientappEventQueries.complex_clientapp_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single complex_clientapp_event.

  Returns nil if the ComplexClientappEvent does not exist.

  ## Examples

      iex> get_complex_clientapp_event(123)
      %ComplexClientappEvent{}

      iex> get_complex_clientapp_event(456)
      nil

  """
  @spec get_complex_clientapp_event(ComplexClientappEvent.id()) :: ComplexClientappEvent.t() | nil
  @spec get_complex_clientapp_event(ComplexClientappEvent.id(), Teiserver.query_args()) ::
          ComplexClientappEvent.t() | nil
  def get_complex_clientapp_event(complex_clientapp_event_id, query_args \\ []) do
    (query_args ++ [id: complex_clientapp_event_id])
    |> ComplexClientappEventQueries.complex_clientapp_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a complex_clientapp_event.

  ## Examples

      iex> create_complex_clientapp_event(%{field: value})
      {:ok, %ComplexClientappEvent{}}

      iex> create_complex_clientapp_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_complex_clientapp_event(map) ::
          {:ok, ComplexClientappEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_complex_clientapp_event(attrs) do
    %ComplexClientappEvent{}
    |> ComplexClientappEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complex_clientapp_event.

  ## Examples

      iex> update_complex_clientapp_event(complex_clientapp_event, %{field: new_value})
      {:ok, %ComplexClientappEvent{}}

      iex> update_complex_clientapp_event(complex_clientapp_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_complex_clientapp_event(ComplexClientappEvent.t(), map) ::
          {:ok, ComplexClientappEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_complex_clientapp_event(%ComplexClientappEvent{} = complex_clientapp_event, attrs) do
    complex_clientapp_event
    |> ComplexClientappEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complex_clientapp_event.

  ## Examples

      iex> delete_complex_clientapp_event(complex_clientapp_event)
      {:ok, %ComplexClientappEvent{}}

      iex> delete_complex_clientapp_event(complex_clientapp_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_complex_clientapp_event(ComplexClientappEvent.t()) ::
          {:ok, ComplexClientappEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_complex_clientapp_event(%ComplexClientappEvent{} = complex_clientapp_event) do
    Repo.delete(complex_clientapp_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complex_clientapp_event changes.

  ## Examples

      iex> change_complex_clientapp_event(complex_clientapp_event)
      %Ecto.Changeset{data: %ComplexClientappEvent{}}

  """
  @spec change_complex_clientapp_event(ComplexClientappEvent.t(), map) :: Ecto.Changeset.t()
  def change_complex_clientapp_event(
        %ComplexClientappEvent{} = complex_clientapp_event,
        attrs \\ %{}
      ) do
    ComplexClientappEvent.changeset(complex_clientapp_event, attrs)
  end
end
