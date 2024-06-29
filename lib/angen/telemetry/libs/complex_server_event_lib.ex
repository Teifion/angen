defmodule Angen.Telemetry.ComplexServerEventLib do
  @moduledoc """
  Library of complex_server_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{ComplexServerEvent, ComplexServerEventQueries}

  @doc """
  A wrapper around create_complex_server_event which handles grabbing the event_type_id
  """
  @spec log_complex_server_event(String.t(), Teiserver.user_id(), map()) :: :ok | {:error, String.t()}
  def log_complex_server_event(name, user_id, details) do
    type_id = Telemetry.get_or_add_event_type_id(name, "complex_server")

    attrs = %{
      event_type_id: type_id,
      user_id: user_id,
      inserted_at: Timex.now(),
      details: details
    }

    case create_complex_server_event(attrs) do
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
  Returns the list of complex_server_events.

  ## Examples

      iex> list_complex_server_events()
      [%ComplexServerEvent{}, ...]

  """
  @spec list_complex_server_events(Teiserver.query_args()) :: [ComplexServerEvent.t()]
  def list_complex_server_events(query_args) do
    query_args
    |> ComplexServerEventQueries.complex_server_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single complex_server_event.

  Raises `Ecto.NoResultsError` if the ComplexServerEvent does not exist.

  ## Examples

      iex> get_complex_server_event!(123)
      %ComplexServerEvent{}

      iex> get_complex_server_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_complex_server_event!(ComplexServerEvent.id()) :: ComplexServerEvent.t()
  @spec get_complex_server_event!(ComplexServerEvent.id(), Teiserver.query_args()) ::
          ComplexServerEvent.t()
  def get_complex_server_event!(complex_server_event_id, query_args \\ []) do
    (query_args ++ [id: complex_server_event_id])
    |> ComplexServerEventQueries.complex_server_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single complex_server_event.

  Returns nil if the ComplexServerEvent does not exist.

  ## Examples

      iex> get_complex_server_event(123)
      %ComplexServerEvent{}

      iex> get_complex_server_event(456)
      nil

  """
  @spec get_complex_server_event(ComplexServerEvent.id()) :: ComplexServerEvent.t() | nil
  @spec get_complex_server_event(ComplexServerEvent.id(), Teiserver.query_args()) ::
          ComplexServerEvent.t() | nil
  def get_complex_server_event(complex_server_event_id, query_args \\ []) do
    (query_args ++ [id: complex_server_event_id])
    |> ComplexServerEventQueries.complex_server_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a complex_server_event.

  ## Examples

      iex> create_complex_server_event(%{field: value})
      {:ok, %ComplexServerEvent{}}

      iex> create_complex_server_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_complex_server_event(map) ::
          {:ok, ComplexServerEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_complex_server_event(attrs) do
    %ComplexServerEvent{}
    |> ComplexServerEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complex_server_event.

  ## Examples

      iex> update_complex_server_event(complex_server_event, %{field: new_value})
      {:ok, %ComplexServerEvent{}}

      iex> update_complex_server_event(complex_server_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_complex_server_event(ComplexServerEvent.t(), map) ::
          {:ok, ComplexServerEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_complex_server_event(%ComplexServerEvent{} = complex_server_event, attrs) do
    complex_server_event
    |> ComplexServerEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complex_server_event.

  ## Examples

      iex> delete_complex_server_event(complex_server_event)
      {:ok, %ComplexServerEvent{}}

      iex> delete_complex_server_event(complex_server_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_complex_server_event(ComplexServerEvent.t()) ::
          {:ok, ComplexServerEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_complex_server_event(%ComplexServerEvent{} = complex_server_event) do
    Repo.delete(complex_server_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complex_server_event changes.

  ## Examples

      iex> change_complex_server_event(complex_server_event)
      %Ecto.Changeset{data: %ComplexServerEvent{}}

  """
  @spec change_complex_server_event(ComplexServerEvent.t(), map) :: Ecto.Changeset.t()
  def change_complex_server_event(
        %ComplexServerEvent{} = complex_server_event,
        attrs \\ %{}
      ) do
    ComplexServerEvent.changeset(complex_server_event, attrs)
  end
end
