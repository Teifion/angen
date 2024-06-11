defmodule Angen.Telemetry.TeiserverCollectorServer do
  @moduledoc """
  A GenServer collecting telemetry values with the purpose of storing them in the database.
  """

  use GenServer
  require Logger
  alias Angen.Telemetry
  # alias Phoenix.PubSub

  @default_state %{
    # Counters
    client_event_counter: %{},
    client_connect_counter: %{},
    client_disconnect_counter: %{},
    lobby_event_counter: %{}
  }

  # @impl true
  # def handle_info(:attach_events, state) do
  #   {:noreply, state}
  # end

  # Client events
  @impl true
  def handle_info({:emit, [:teiserver, :client, :event], %{type: type}, _meta, _opts}, state) do
    new_count = Map.get(state.client_event_counter, type, 0) + 1
    new_counter = Map.put(state.client_event_counter, type, new_count)

    {:noreply, %{state | client_event_counter: new_counter}}
  end

  def handle_info({:emit, [:teiserver, :client, :connect], %{type: type}, meta, _opts}, state) do
    new_count = Map.get(state.client_connect_counter, type, 0) + 1
    new_counter = Map.put(state.client_connect_counter, type, new_count)

    Telemetry.log_simple_clientapp_event("connected", meta.user_id)

    {:noreply, %{state | client_connect_counter: new_counter}}
  end

  def handle_info({:emit, [:teiserver, :client, :disconnect], %{reason: reason}, meta, _opts}, state) do
    new_count = Map.get(state.client_disconnect_counter, reason, 0) + 1
    new_counter = Map.put(state.client_disconnect_counter, reason, new_count)

    Telemetry.log_simple_clientapp_event("disconnected", meta.user_id)

    {:noreply, %{state | client_disconnect_counter: new_counter}}
  end

  # Lobby events
  def handle_info({:emit, [:teiserver, :lobby, :event], %{type: type}, _meta, _opts}, state) do
    new_count = Map.get(state.lobby_event_counter, type, 0) + 1
    new_counter = Map.put(state.lobby_event_counter, type, new_count)

    {:noreply, %{state | lobby_event_counter: new_counter}}
  end

  def handle_info({:emit, [:teiserver, :lobby, :cycle], _data, meta, _opts}, state) do
    new_count = Map.get(state.lobby_event_counter, :cycle, 0) + 1
    new_counter = Map.put(state.lobby_event_counter, :cycle, new_count)

    :ok = Telemetry.log_simple_lobby_event("cycle", meta.match_id, meta[:user_id])

    {:noreply, %{state | lobby_event_counter: new_counter}}
  end

  def handle_info({:emit, [:teiserver, :lobby, :start_match], _, meta, _opts}, state) do
    new_count = Map.get(state.lobby_event_counter, :start_match, 0) + 1
    new_counter = Map.put(state.lobby_event_counter, :start_match, new_count)

    :ok = Telemetry.log_simple_lobby_event("start_match", meta.match_id, meta[:user_id])

    {:noreply, %{state | lobby_event_counter: new_counter}}
  end

  def handle_info({:emit, _event, _measurement, _meta, _opts} = _msg, state) do
    # IO.puts "#{__MODULE__}:#{__ENV__.line}"
    # IO.inspect "No telemetry handler for"
    # IO.inspect elem(msg, 1)
    # IO.inspect elem(msg, 2)
    # IO.inspect elem(msg, 3)
    # IO.inspect elem(msg, 4)
    # IO.puts ""

    {:noreply, state}
  end

  @impl true
  def handle_call(:get_totals_and_reset, _from, state) do
    {:reply, get_totals(state), @default_state}
  end

  def handle_call(:get_totals, _from, state) do
    {:reply, get_totals(state), state}
  end

  @spec get_totals(Map.t()) :: Map.t()
  defp get_totals(state) do
    state
  end

  # Startup
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:opts], opts)
  end

  def handle_event(event, measure, meta, opts) do
    # Currently we have one genserver handling everything
    # I think a smart method would be to have a different genserver for each group
    # of events (in particular things like commands which will be more complex)
    # and then have the perist job just call each of them and do stuff

    # Example event
    # [:teiserver, :client, :new_connection], %{}, %{user_id: "f41c10c2-e8bf-4422-9584-4b03d49aa383"}, []

    # Angen.Telemetry.CollectorServer.handle_event([:teiserver, :client, :new_connection], %{}, %{user_id: "f41c10c2-e8bf-4422-9584-4b03d49aa383"}, [])

    send(Angen.Telemetry.TeiserverCollectorServer, {:emit, event, measure, meta, opts})
  end

  @impl true
  def init(_opts) do
    {:ok, @default_state}
  end
end
