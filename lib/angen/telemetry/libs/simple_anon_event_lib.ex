defmodule Angen.Telemetry.SimpleAnonEventLib do
  @moduledoc """
  Library of simple_anon_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{SimpleAnonEvent, SimpleAnonEventQueries}

  @doc """
  A wrapper around create_simple_anon_event which handles grabbing the event_type_id
  """
  @spec log_simple_anon_event(String.t(), Ecto.UUID.t()) :: :ok | {:error, String.t()}
  def log_simple_anon_event(name, hash_id) do
    type_id = Telemetry.get_or_add_event_type_id(name, "simple_anon")

    attrs = %{
      event_type_id: type_id,
      hash_id: hash_id,
      inserted_at: Timex.now()
    }

    case create_simple_anon_event(attrs) do
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
  Returns the list of simple_anon_events.

  ## Examples

      iex> list_simple_anon_events()
      [%SimpleAnonEvent{}, ...]

  """
  @spec list_simple_anon_events(Teiserver.query_args()) :: [SimpleAnonEvent.t()]
  def list_simple_anon_events(query_args) do
    query_args
    |> SimpleAnonEventQueries.simple_anon_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_anon_event.

  Raises `Ecto.NoResultsError` if the SimpleAnonEvent does not exist.

  ## Examples

      iex> get_simple_anon_event!(123)
      %SimpleAnonEvent{}

      iex> get_simple_anon_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_anon_event!(SimpleAnonEvent.id()) :: SimpleAnonEvent.t()
  @spec get_simple_anon_event!(SimpleAnonEvent.id(), Teiserver.query_args()) ::
          SimpleAnonEvent.t()
  def get_simple_anon_event!(simple_anon_event_id, query_args \\ []) do
    (query_args ++ [id: simple_anon_event_id])
    |> SimpleAnonEventQueries.simple_anon_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_anon_event.

  Returns nil if the SimpleAnonEvent does not exist.

  ## Examples

      iex> get_simple_anon_event(123)
      %SimpleAnonEvent{}

      iex> get_simple_anon_event(456)
      nil

  """
  @spec get_simple_anon_event(SimpleAnonEvent.id()) :: SimpleAnonEvent.t() | nil
  @spec get_simple_anon_event(SimpleAnonEvent.id(), Teiserver.query_args()) ::
          SimpleAnonEvent.t() | nil
  def get_simple_anon_event(simple_anon_event_id, query_args \\ []) do
    (query_args ++ [id: simple_anon_event_id])
    |> SimpleAnonEventQueries.simple_anon_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_anon_event.

  ## Examples

      iex> create_simple_anon_event(%{field: value})
      {:ok, %SimpleAnonEvent{}}

      iex> create_simple_anon_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_anon_event(map) ::
          {:ok, SimpleAnonEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_anon_event(attrs) do
    %SimpleAnonEvent{}
    |> SimpleAnonEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a simple_anon_event.

  ## Examples

      iex> update_simple_anon_event(simple_anon_event, %{field: new_value})
      {:ok, %SimpleAnonEvent{}}

      iex> update_simple_anon_event(simple_anon_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_anon_event(SimpleAnonEvent.t(), map) ::
          {:ok, SimpleAnonEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_anon_event(%SimpleAnonEvent{} = simple_anon_event, attrs) do
    simple_anon_event
    |> SimpleAnonEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a simple_anon_event.

  ## Examples

      iex> delete_simple_anon_event(simple_anon_event)
      {:ok, %SimpleAnonEvent{}}

      iex> delete_simple_anon_event(simple_anon_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_anon_event(SimpleAnonEvent.t()) ::
          {:ok, SimpleAnonEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_anon_event(%SimpleAnonEvent{} = simple_anon_event) do
    Repo.delete(simple_anon_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_anon_event changes.

  ## Examples

      iex> change_simple_anon_event(simple_anon_event)
      %Ecto.Changeset{data: %SimpleAnonEvent{}}

  """
  @spec change_simple_anon_event(SimpleAnonEvent.t(), map) :: Ecto.Changeset.t()
  def change_simple_anon_event(
        %SimpleAnonEvent{} = simple_anon_event,
        attrs \\ %{}
      ) do
    SimpleAnonEvent.changeset(simple_anon_event, attrs)
  end
end
