defmodule Angen.Telemetry do
  @moduledoc """
  This page is a reference for the Telemetry data functions. For a guide on how to use the Telemetry features please refer to the [telemetry guide](guides/telemetry_events.md).

  The contextual module for:
  - `Angen.Telemetry.EventType`

  - `Angen.Telemetry.SimpleGameEvent`
  - `Angen.Telemetry.SimpleServerEvent`
  - `Angen.Telemetry.SimpleLobbyEvent`
  - `Angen.Telemetry.SimpleUserEvent`
  - `Angen.Telemetry.SimpleClientEvent`
  - `Angen.Telemetry.SimpleAnonEvent`

  - `Angen.Telemetry.ComplexGameEvent`
  - `Angen.Telemetry.ComplexServerEvent`
  - `Angen.Telemetry.ComplexLobbyEvent`
  - `Angen.Telemetry.ComplexUserEvent`
  - `Angen.Telemetry.ComplexClientEvent`
  - `Angen.Telemetry.ComplexAnonEvent`
  """

  def event_list() do
    [
      [:angen, :protocol, :response],
      [:angen, :protocol, :response, :start],
      [:angen, :protocol, :response, :stop]

      # [:angen, :proto, :response]
    ]
  end

  # EventTypes
  alias Angen.Telemetry.{EventType, EventTypeLib, EventTypeQueries}

  @doc false
  @spec event_type_query(Angen.query_args()) :: Ecto.Query.t()
  defdelegate event_type_query(args), to: EventTypeQueries

  @doc section: :event_type
  @spec list_event_types(Angen.query_args()) :: [EventType.t()]
  defdelegate list_event_types(args), to: EventTypeLib

  @doc section: :event_type
  @spec get_event_type!(EventType.id()) :: EventType.t()
  @spec get_event_type!(EventType.id(), Angen.query_args()) :: EventType.t()
  defdelegate get_event_type!(event_type_id, query_args \\ []), to: EventTypeLib

  @doc section: :event_type
  @spec get_event_type(EventType.id()) :: EventType.t() | nil
  @spec get_event_type(EventType.id(), Angen.query_args()) :: EventType.t() | nil
  defdelegate get_event_type(event_type_id, query_args \\ []), to: EventTypeLib

  @doc section: :event_type
  @spec create_event_type(map) :: {:ok, EventType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_event_type(attrs), to: EventTypeLib

  @doc section: :event_type
  @spec update_event_type(EventType, map) :: {:ok, EventType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_event_type(event_type, attrs), to: EventTypeLib

  @doc section: :event_type
  @spec delete_event_type(EventType.t()) :: {:ok, EventType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_event_type(event_type), to: EventTypeLib

  @doc section: :event_type
  @spec change_event_type(EventType.t()) :: Ecto.Changeset.t()
  @spec change_event_type(EventType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_event_type(event_type, attrs \\ %{}), to: EventTypeLib
end
