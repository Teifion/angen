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

  alias Angen.Telemetry.TelemetryLib

  @doc false
  @spec event_list() :: [[atom]]
  defdelegate event_list(), to: TelemetryLib

  # EventTypes
  alias Angen.Telemetry.{EventType, EventTypeLib, EventTypeQueries}

  @doc section: :event_type
  @spec get_or_add_event_type_id(name :: String.t(), category :: String.t()) :: EventType.id()
  defdelegate get_or_add_event_type_id(name, category), to: EventTypeLib

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

  # SimpleClientappEvents
  alias Angen.Telemetry.{
    SimpleClientappEvent,
    SimpleClientappEventLib,
    SimpleClientappEventQueries
  }

  @doc section: :simple_clientapp_event
  @spec log_simple_clientapp_event(String.t(), Teiserver.user_id()) :: :ok | {:error, String.t()}
  defdelegate log_simple_clientapp_event(name, user_id), to: SimpleClientappEventLib

  @doc false
  @spec simple_clientapp_event_query(Angen.query_args()) :: Ecto.Query.t()
  defdelegate simple_clientapp_event_query(args), to: SimpleClientappEventQueries

  @doc section: :simple_clientapp_event
  @spec list_simple_clientapp_events(Teiserver.query_args()) :: [SimpleClientappEvent.t()]
  defdelegate list_simple_clientapp_events(args), to: SimpleClientappEventLib

  @doc section: :simple_clientapp_event
  @spec simple_clientapp_events_summary(list) :: map()
  defdelegate simple_clientapp_events_summary(args), to: SimpleClientappEventQueries

  # SimpleLobbyEvents
  alias Angen.Telemetry.{SimpleLobbyEvent, SimpleLobbyEventLib, SimpleLobbyEventQueries}

  @doc section: :simple_lobby_event
  @spec log_simple_lobby_event(String.t(), Teiserver.match_id(), Teiserver.user_id()) ::
          :ok | {:error, String.t()}
  defdelegate log_simple_lobby_event(name, match_id, user_id \\ nil), to: SimpleLobbyEventLib

  @doc false
  @spec simple_lobby_event_query(Angen.query_args()) :: Ecto.Query.t()
  defdelegate simple_lobby_event_query(args), to: SimpleLobbyEventQueries

  @doc section: :simple_lobby_event
  @spec list_simple_lobby_events(Teiserver.query_args()) :: [SimpleLobbyEvent.t()]
  defdelegate list_simple_lobby_events(args), to: SimpleLobbyEventLib

  @doc section: :simple_lobby_event
  @spec simple_lobby_events_summary(list) :: map()
  defdelegate simple_lobby_events_summary(args), to: SimpleLobbyEventQueries
end
