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
  @spec event_type_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate event_type_query(args), to: EventTypeQueries

  @doc section: :event_type
  @spec list_event_types(Teiserver.query_args()) :: [EventType.t()]
  defdelegate list_event_types(args), to: EventTypeLib

  @doc section: :event_type
  @spec get_event_type!(EventType.id()) :: EventType.t()
  @spec get_event_type!(EventType.id(), Teiserver.query_args()) :: EventType.t()
  defdelegate get_event_type!(event_type_id, query_args \\ []), to: EventTypeLib

  @doc section: :event_type
  @spec get_event_type(EventType.id()) :: EventType.t() | nil
  @spec get_event_type(EventType.id(), Teiserver.query_args()) :: EventType.t() | nil
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

  # SimpleAnonEvents
  alias Angen.Telemetry.{
    SimpleAnonEvent,
    SimpleAnonEventLib,
    SimpleAnonEventQueries
  }

  @doc section: :simple_anon_event
  @spec log_simple_anon_event(String.t(), Ecto.UUID.t()) :: :ok | {:error, String.t()}
  defdelegate log_simple_anon_event(name, hash_id), to: SimpleAnonEventLib

  @doc false
  @spec simple_anon_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate simple_anon_event_query(args), to: SimpleAnonEventQueries

  @doc section: :simple_anon_event
  @spec list_simple_anon_events(Teiserver.query_args()) :: [SimpleAnonEvent.t()]
  defdelegate list_simple_anon_events(args), to: SimpleAnonEventLib

  @doc section: :simple_anon_event
  @spec simple_anon_events_summary(list) :: map()
  defdelegate simple_anon_events_summary(args), to: SimpleAnonEventQueries

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
  @spec simple_clientapp_event_query(Teiserver.query_args()) :: Ecto.Query.t()
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
  @spec simple_lobby_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate simple_lobby_event_query(args), to: SimpleLobbyEventQueries

  @doc section: :simple_lobby_event
  @spec list_simple_lobby_events(Teiserver.query_args()) :: [SimpleLobbyEvent.t()]
  defdelegate list_simple_lobby_events(args), to: SimpleLobbyEventLib

  @doc section: :simple_lobby_event
  @spec simple_lobby_events_summary(list) :: map()
  defdelegate simple_lobby_events_summary(args), to: SimpleLobbyEventQueries

  # SimpleMatchEvents
  alias Angen.Telemetry.{SimpleMatchEvent, SimpleMatchEventLib, SimpleMatchEventQueries}

  @doc section: :simple_match_event
  @spec log_simple_match_event(
          String.t(),
          Teiserver.match_id(),
          Teiserver.user_id(),
          non_neg_integer()
        ) ::
          :ok | {:error, String.t()}
  defdelegate log_simple_match_event(name, match_id, user_id, game_seconds),
    to: SimpleMatchEventLib

  @doc false
  @spec simple_match_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate simple_match_event_query(args), to: SimpleMatchEventQueries

  @doc section: :simple_match_event
  @spec list_simple_match_events(Teiserver.query_args()) :: [SimpleMatchEvent.t()]
  defdelegate list_simple_match_events(args), to: SimpleMatchEventLib

  @doc section: :simple_match_event
  @spec simple_match_events_summary(list) :: map()
  defdelegate simple_match_events_summary(args), to: SimpleMatchEventQueries

  # SimpleServerEvents
  alias Angen.Telemetry.{
    SimpleServerEvent,
    SimpleServerEventLib,
    SimpleServerEventQueries
  }

  @doc section: :simple_server_event
  @spec log_simple_server_event(String.t(), Teiserver.user_id()) :: :ok | {:error, String.t()}
  defdelegate log_simple_server_event(name, user_id), to: SimpleServerEventLib

  @doc false
  @spec simple_server_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate simple_server_event_query(args), to: SimpleServerEventQueries

  @doc section: :simple_server_event
  @spec list_simple_server_events(Teiserver.query_args()) :: [SimpleServerEvent.t()]
  defdelegate list_simple_server_events(args), to: SimpleServerEventLib

  @doc section: :simple_server_event
  @spec simple_server_events_summary(list) :: map()
  defdelegate simple_server_events_summary(args), to: SimpleServerEventQueries

  # ComplexAnonEvents
  alias Angen.Telemetry.{
    ComplexAnonEvent,
    ComplexAnonEventLib,
    ComplexAnonEventQueries
  }

  @doc section: :complex_anon_event
  @spec log_complex_anon_event(String.t(), Ecto.UUID.t(), map()) :: :ok | {:error, String.t()}
  defdelegate log_complex_anon_event(name, hash_id, details), to: ComplexAnonEventLib

  @doc false
  @spec complex_anon_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate complex_anon_event_query(args), to: ComplexAnonEventQueries

  @doc section: :complex_anon_event
  @spec list_complex_anon_events(Teiserver.query_args()) :: [ComplexAnonEvent.t()]
  defdelegate list_complex_anon_events(args), to: ComplexAnonEventLib

  @doc section: :complex_anon_event
  @spec complex_anon_events_summary(list) :: map()
  defdelegate complex_anon_events_summary(args), to: ComplexAnonEventQueries

  # ComplexClientappEvents
  alias Angen.Telemetry.{
    ComplexClientappEvent,
    ComplexClientappEventLib,
    ComplexClientappEventQueries
  }

  @doc section: :complex_clientapp_event
  @spec log_complex_clientapp_event(String.t(), Teiserver.user_id(), map()) ::
          :ok | {:error, String.t()}
  defdelegate log_complex_clientapp_event(name, user_id, details), to: ComplexClientappEventLib

  @doc false
  @spec complex_clientapp_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate complex_clientapp_event_query(args), to: ComplexClientappEventQueries

  @doc section: :complex_clientapp_event
  @spec list_complex_clientapp_events(Teiserver.query_args()) :: [ComplexClientappEvent.t()]
  defdelegate list_complex_clientapp_events(args), to: ComplexClientappEventLib

  @doc section: :complex_clientapp_event
  @spec complex_clientapp_events_summary(list) :: map()
  defdelegate complex_clientapp_events_summary(args), to: ComplexClientappEventQueries

  # ComplexLobbyEvents
  alias Angen.Telemetry.{ComplexLobbyEvent, ComplexLobbyEventLib, ComplexLobbyEventQueries}

  @doc section: :complex_lobby_event
  @spec log_complex_lobby_event(String.t(), Teiserver.match_id(), Teiserver.user_id(), map()) ::
          :ok | {:error, String.t()}
  defdelegate log_complex_lobby_event(name, match_id, user_id \\ nil, details),
    to: ComplexLobbyEventLib

  @doc false
  @spec complex_lobby_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate complex_lobby_event_query(args), to: ComplexLobbyEventQueries

  @doc section: :complex_lobby_event
  @spec list_complex_lobby_events(Teiserver.query_args()) :: [ComplexLobbyEvent.t()]
  defdelegate list_complex_lobby_events(args), to: ComplexLobbyEventLib

  @doc section: :complex_lobby_event
  @spec complex_lobby_events_summary(list) :: map()
  defdelegate complex_lobby_events_summary(args), to: ComplexLobbyEventQueries

  # ComplexMatchEvents
  alias Angen.Telemetry.{ComplexMatchEvent, ComplexMatchEventLib, ComplexMatchEventQueries}

  @doc section: :complex_match_event
  @spec log_complex_match_event(
          String.t(),
          Teiserver.match_id(),
          Teiserver.user_id(),
          non_neg_integer(),
          map()
        ) ::
          :ok | {:error, String.t()}
  defdelegate log_complex_match_event(name, match_id, user_id, game_seconds, details),
    to: ComplexMatchEventLib

  @doc false
  @spec complex_match_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate complex_match_event_query(args), to: ComplexMatchEventQueries

  @doc section: :complex_match_event
  @spec list_complex_match_events(Teiserver.query_args()) :: [ComplexMatchEvent.t()]
  defdelegate list_complex_match_events(args), to: ComplexMatchEventLib

  @doc section: :complex_match_event
  @spec complex_match_events_summary(list) :: map()
  defdelegate complex_match_events_summary(args), to: ComplexMatchEventQueries

  # ComplexServerEvents
  alias Angen.Telemetry.{
    ComplexServerEvent,
    ComplexServerEventLib,
    ComplexServerEventQueries
  }

  @doc section: :complex_server_event
  @spec log_complex_server_event(String.t(), Teiserver.user_id(), map()) ::
          :ok | {:error, String.t()}
  defdelegate log_complex_server_event(name, user_id, details), to: ComplexServerEventLib

  @doc false
  @spec complex_server_event_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate complex_server_event_query(args), to: ComplexServerEventQueries

  @doc section: :complex_server_event
  @spec list_complex_server_events(Teiserver.query_args()) :: [ComplexServerEvent.t()]
  defdelegate list_complex_server_events(args), to: ComplexServerEventLib

  @doc section: :complex_server_event
  @spec complex_server_events_summary(list) :: map()
  defdelegate complex_server_events_summary(args), to: ComplexServerEventQueries
end
