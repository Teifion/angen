defmodule Angen.Telemetry.AngenCollectorServer do
  @moduledoc """
  A GenServer collecting telemetry values with the purpose of storing them in the database.
  """

  use GenServer
  require Logger
  # alias Phoenix.PubSub

  @default_state %{
    db_persist: true,

    # Counters
    protocol_command_count: %{},
    protocol_command_time: %{}
  }

  # @impl true
  # def handle_info(:attach_events, state) do
  #   {:noreply, state}
  # end

  # Client events
  @impl true
  def handle_info({:set_db_persist, new_value}, state) do
    {:noreply, %{state | db_persist: new_value}}
  end

  def handle_info(
        {:emit, [:angen, :protocol, :response, :start], _measurement, _meta, _opts},
        state
      ) do
    # new_count = Map.get(state.protocol_counter, type, 0) + 1
    # new_counter = Map.put(state.protocol_counter, type, new_count)

    {:noreply, state}
  end

  def handle_info(
        {:emit, [:angen, :protocol, :response, :stop], %{duration: duration},
         %{name: name} = _meta, _opts},
        state
      ) do
    new_count = Map.get(state.protocol_command_count, name, 0) + 1
    new_counter = Map.put(state.protocol_command_count, name, new_count)

    new_time = Map.get(state.protocol_command_time, name, 0) + duration
    new_timer = Map.put(state.protocol_command_time, name, new_time)

    {:noreply, %{state | protocol_command_count: new_counter, protocol_command_time: new_timer}}
  end

  # def handle_info({:emit, [:teiserver, :client, :disconnect], %{reason: reason}, _meta, _opts}, state) do
  #   new_count = Map.get(state.client_disconnect_counter, reason, 0) + 1
  #   new_counter = Map.put(state.client_disconnect_counter, reason, new_count)

  #   {:noreply, %{state | client_disconnect_counter: new_counter}}
  # end

  # def handle_info({:emit, [:teiserver, :lobby, :event], %{type: type}, _meta, _opts}, state) do
  #   new_count = Map.get(state.lobby_event_counter, type, 0) + 1
  #   new_counter = Map.put(state.lobby_event_counter, type, new_count)

  #   {:noreply, %{state | lobby_event_counter: new_counter}}
  # end

  def handle_info({:emit, _event, _measurement, _meta, _opts} = _msg, state) do
    # IO.puts "#{__MODULE__}:#{__ENV__.line}"
    # IO.inspect "No telemetry handler for event: #{inspect elem(msg, 1)}"
    # IO.inspect elem(msg, 2), label: "Measurement: "
    # IO.inspect elem(msg, 3), label: "Meta: "
    # IO.inspect elem(msg, 4), label: "Opts: "
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
    Map.drop(state, [:db_persist])
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

    send(Angen.Telemetry.AngenCollectorServer, {:emit, event, measure, meta, opts})
  end

  @impl true
  def init(_opts) do
    {:ok, @default_state}
  end
end
