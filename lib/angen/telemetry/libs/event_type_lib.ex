defmodule Angen.Telemetry.EventTypeLib do
  @moduledoc """
  Library of event_type related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Telemetry.{EventType, EventTypeQueries}

  @doc """
  Returns the list of event_types.

  ## Examples

      iex> list_event_types()
      [%EventType{}, ...]

  """
  @spec list_event_types(Teiserver.query_args()) :: [EventType.t()]
  def list_event_types(query_args) do
    query_args
    |> EventTypeQueries.event_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single event_type.

  Raises `Ecto.NoResultsError` if the EventType does not exist.

  ## Examples

      iex> get_event_type!(123)
      %EventType{}

      iex> get_event_type!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_event_type!(EventType.id()) :: EventType.t()
  @spec get_event_type!(EventType.id(), Teiserver.query_args()) :: EventType.t()
  def get_event_type!(event_type_id, query_args \\ []) do
    (query_args ++ [id: event_type_id])
    |> EventTypeQueries.event_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single event_type.

  Returns nil if the EventType does not exist.

  ## Examples

      iex> get_event_type(123)
      %EventType{}

      iex> get_event_type(456)
      nil

  """
  @spec get_event_type(EventType.id()) :: EventType.t() | nil
  @spec get_event_type(EventType.id(), Teiserver.query_args()) :: EventType.t() | nil
  def get_event_type(event_type_id, query_args \\ []) do
    (query_args ++ [id: event_type_id])
    |> EventTypeQueries.event_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a event_type.

  ## Examples

      iex> create_event_type(%{field: value})
      {:ok, %EventType{}}

      iex> create_event_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_event_type(map) :: {:ok, EventType.t()} | {:error, Ecto.Changeset.t()}
  def create_event_type(attrs) do
    %EventType{}
    |> EventType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event_type.

  ## Examples

      iex> update_event_type(event_type, %{field: new_value})
      {:ok, %EventType{}}

      iex> update_event_type(event_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_event_type(EventType.t(), map) ::
          {:ok, EventType.t()} | {:error, Ecto.Changeset.t()}
  def update_event_type(%EventType{} = event_type, attrs) do
    event_type
    |> EventType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_type.

  ## Examples

      iex> delete_event_type(event_type)
      {:ok, %EventType{}}

      iex> delete_event_type(event_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_event_type(EventType.t()) :: {:ok, EventType.t()} | {:error, Ecto.Changeset.t()}
  def delete_event_type(%EventType{} = event_type) do
    Repo.delete(event_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_type changes.

  ## Examples

      iex> change_event_type(event_type)
      %Ecto.Changeset{data: %EventType{}}

  """
  @spec change_event_type(EventType.t(), map) :: Ecto.Changeset.t()
  def change_event_type(%EventType{} = event_type, attrs \\ %{}) do
    EventType.changeset(event_type, attrs)
  end
end
