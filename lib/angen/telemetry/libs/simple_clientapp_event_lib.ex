defmodule Angen.Telemetry.SimpleClientappEventLib do
  @moduledoc """
  Library of simple_clientapp_event related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry
  alias Angen.Telemetry.{SimpleClientappEvent, SimpleClientappEventQueries}

  @doc """
  A wrapper around create_simple_clientapp_event which handles grabbing the event_type_id
  """
  @spec log_simple_clientapp_event(String.t(), Teiserver.user_id()) :: :ok | {:error, String.t()}
  def log_simple_clientapp_event(name, user_id) do
    type_id = Telemetry.get_or_add_event_type_id(name, "simple_clientapp")

    attrs = %{
      event_type_id: type_id,
      user_id: user_id,
      inserted_at: Timex.now()
    }

    case create_simple_clientapp_event(attrs) do
      {:ok, _event} -> :ok
      {:error, changeset} ->
        IO.puts "#{__MODULE__}:#{__ENV__.line}"
        IO.inspect attrs
        IO.puts ""

        IO.puts "#{__MODULE__}:#{__ENV__.line}"
        IO.inspect changeset
        IO.puts ""

        {:error,
          changeset.errors
          |> Enum.map_join(", ", fn {key, {message, _}} ->
            "#{key}: #{message}"
          end)
        }
    end
  end

  @doc """
  Returns the list of simple_clientapp_events.

  ## Examples

      iex> list_simple_clientapp_events()
      [%SimpleClientappEvent{}, ...]

  """
  @spec list_simple_clientapp_events(Teiserver.query_args()) :: [SimpleClientappEvent.t()]
  def list_simple_clientapp_events(query_args) do
    query_args
    |> SimpleClientappEventQueries.simple_clientapp_event_query()
    |> Repo.all()
  end

  @doc """
  Gets a single simple_clientapp_event.

  Raises `Ecto.NoResultsError` if the SimpleClientappEvent does not exist.

  ## Examples

      iex> get_simple_clientapp_event!(123)
      %SimpleClientappEvent{}

      iex> get_simple_clientapp_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_simple_clientapp_event!(SimpleClientappEvent.id()) :: SimpleClientappEvent.t()
  @spec get_simple_clientapp_event!(SimpleClientappEvent.id(), Teiserver.query_args()) :: SimpleClientappEvent.t()
  def get_simple_clientapp_event!(simple_clientapp_event_id, query_args \\ []) do
    (query_args ++ [id: simple_clientapp_event_id])
    |> SimpleClientappEventQueries.simple_clientapp_event_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single simple_clientapp_event.

  Returns nil if the SimpleClientappEvent does not exist.

  ## Examples

      iex> get_simple_clientapp_event(123)
      %SimpleClientappEvent{}

      iex> get_simple_clientapp_event(456)
      nil

  """
  @spec get_simple_clientapp_event(SimpleClientappEvent.id()) :: SimpleClientappEvent.t() | nil
  @spec get_simple_clientapp_event(SimpleClientappEvent.id(), Teiserver.query_args()) :: SimpleClientappEvent.t() | nil
  def get_simple_clientapp_event(simple_clientapp_event_id, query_args \\ []) do
    (query_args ++ [id: simple_clientapp_event_id])
    |> SimpleClientappEventQueries.simple_clientapp_event_query()
    |> Repo.one()
  end

  @doc """
  Creates a simple_clientapp_event.

  ## Examples

      iex> create_simple_clientapp_event(%{field: value})
      {:ok, %SimpleClientappEvent{}}

      iex> create_simple_clientapp_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_simple_clientapp_event(map) :: {:ok, SimpleClientappEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_simple_clientapp_event(attrs) do
    %SimpleClientappEvent{}
    |> SimpleClientappEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a simple_clientapp_event.

  ## Examples

      iex> update_simple_clientapp_event(simple_clientapp_event, %{field: new_value})
      {:ok, %SimpleClientappEvent{}}

      iex> update_simple_clientapp_event(simple_clientapp_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_simple_clientapp_event(SimpleClientappEvent.t(), map) ::
          {:ok, SimpleClientappEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_simple_clientapp_event(%SimpleClientappEvent{} = simple_clientapp_event, attrs) do
    simple_clientapp_event
    |> SimpleClientappEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a simple_clientapp_event.

  ## Examples

      iex> delete_simple_clientapp_event(simple_clientapp_event)
      {:ok, %SimpleClientappEvent{}}

      iex> delete_simple_clientapp_event(simple_clientapp_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_simple_clientapp_event(SimpleClientappEvent.t()) :: {:ok, SimpleClientappEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_simple_clientapp_event(%SimpleClientappEvent{} = simple_clientapp_event) do
    Repo.delete(simple_clientapp_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simple_clientapp_event changes.

  ## Examples

      iex> change_simple_clientapp_event(simple_clientapp_event)
      %Ecto.Changeset{data: %SimpleClientappEvent{}}

  """
  @spec change_simple_clientapp_event(SimpleClientappEvent.t(), map) :: Ecto.Changeset.t()
  def change_simple_clientapp_event(%SimpleClientappEvent{} = simple_clientapp_event, attrs \\ %{}) do
    SimpleClientappEvent.changeset(simple_clientapp_event, attrs)
  end
end
