defmodule Angen.Telemetry.SimpleServerEventLib do
  @moduledoc """
  Library of simple_server_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{SimpleServerEvent, SimpleServerEventQueries}

  @doc """
  A wrapper around create_simple_server_event which handles grabbing the event_type_id
  """
  @spec log_simple_server_event(String.t(), Teiserver.user_id()) :: :ok | {:error, String.t()}
  def log_simple_server_event(name, user_id) do
    type_id = Telemetry.get_or_add_event_type_id(name, "simple_server")

    attrs = %{
      event_type_id: type_id,
      user_id: user_id,
      inserted_at: Timex.now()
    }

    case create_simple_server_event(attrs) do
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
  Returns the list of simple_server_events.

  ## Examples

      iex> list_simple_server_events()
      [%SimpleServerEvent{}, ...]

  """
  @spec list_simple_server_events(Teiserver.query_args()) :: [SimpleServerEvent.t()]
  def list_simple_server_events(query_args) do
    query_args
    |> SimpleServerEventQueries.simple_server_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_server_event.

  Raises `Ecto.NoResultsError` if the SimpleServerEvent does not exist.

  ## Examples

      iex> get_simple_server_event!(123)
      %SimpleServerEvent{}

      iex> get_simple_server_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_server_event!(SimpleServerEvent.id()) :: SimpleServerEvent.t()
  @spec get_simple_server_event!(SimpleServerEvent.id(), Teiserver.query_args()) ::
          SimpleServerEvent.t()
  def get_simple_server_event!(simple_server_event_id, query_args \\ []) do
    (query_args ++ [id: simple_server_event_id])
    |> SimpleServerEventQueries.simple_server_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_server_event.

  Returns nil if the SimpleServerEvent does not exist.

  ## Examples

      iex> get_simple_server_event(123)
      %SimpleServerEvent{}

      iex> get_simple_server_event(456)
      nil

  """
  @spec get_simple_server_event(SimpleServerEvent.id()) :: SimpleServerEvent.t() | nil
  @spec get_simple_server_event(SimpleServerEvent.id(), Teiserver.query_args()) ::
          SimpleServerEvent.t() | nil
  def get_simple_server_event(simple_server_event_id, query_args \\ []) do
    (query_args ++ [id: simple_server_event_id])
    |> SimpleServerEventQueries.simple_server_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_server_event.

  ## Examples

      iex> create_simple_server_event(%{field: value})
      {:ok, %SimpleServerEvent{}}

      iex> create_simple_server_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_server_event(map) ::
          {:ok, SimpleServerEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_server_event(attrs) do
    %SimpleServerEvent{}
    |> SimpleServerEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a simple_server_event.

  ## Examples

      iex> update_simple_server_event(simple_server_event, %{field: new_value})
      {:ok, %SimpleServerEvent{}}

      iex> update_simple_server_event(simple_server_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_server_event(SimpleServerEvent.t(), map) ::
          {:ok, SimpleServerEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_server_event(%SimpleServerEvent{} = simple_server_event, attrs) do
    simple_server_event
    |> SimpleServerEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a simple_server_event.

  ## Examples

      iex> delete_simple_server_event(simple_server_event)
      {:ok, %SimpleServerEvent{}}

      iex> delete_simple_server_event(simple_server_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_server_event(SimpleServerEvent.t()) ::
          {:ok, SimpleServerEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_server_event(%SimpleServerEvent{} = simple_server_event) do
    Repo.delete(simple_server_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_server_event changes.

  ## Examples

      iex> change_simple_server_event(simple_server_event)
      %Ecto.Changeset{data: %SimpleServerEvent{}}

  """
  @spec change_simple_server_event(SimpleServerEvent.t(), map) :: Ecto.Changeset.t()
  def change_simple_server_event(
        %SimpleServerEvent{} = simple_server_event,
        attrs \\ %{}
      ) do
    SimpleServerEvent.changeset(simple_server_event, attrs)
  end
end
