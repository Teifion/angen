defmodule Angen.Telemetry.CollectorServer do
  @moduledoc """
  A GenServer collecting telemetry values with the purpose of storing them in the database.
  """

  use GenServer
  require Logger
  alias Phoenix.PubSub

  @default_state %{
    # Counters
    client_event_counter: %{},
    client_disconnect_counter: %{},
    lobby_event_counter: %{}
  }

  # @impl true
  # def handle_info(:attach_events, state) do
  #   {:noreply, state}
  # end

  # Client events
  def handle_info({:emit, [:teiserver, :client, :event], %{type: type}, _meta, _opts}, state) do
    new_count = Map.get(state.client_event_counter, type, 0) + 1
    new_counter = Map.put(state.client_event_counter, type, new_count)

    {:noreply, %{state | client_event_counter: new_counter}}
  end

  def handle_info({:emit, [:teiserver, :client, :disconnect], %{reason: reason}, _meta, _opts}, state) do
    new_count = Map.get(state.client_disconnect_counter, reason, 0) + 1
    new_counter = Map.put(state.client_disconnect_counter, reason, new_count)

    {:noreply, %{state | client_disconnect_counter: new_counter}}
  end

  def handle_info({:emit, [:teiserver, :lobby, :event], %{type: type}, _meta, _opts}, state) do
    new_count = Map.get(state.lobby_event_counter, type, 0) + 1
    new_counter = Map.put(state.lobby_event_counter, type, new_count)

    {:noreply, %{state | lobby_event_counter: new_counter}}
  end

  def handle_info({:emit, event, measurement, meta, opts}, state) do
    # IO.puts "#{__MODULE__}:#{__ENV__.line}"
    # IO.inspect "No telemetry handler for"
    # IO.inspect event
    # IO.inspect measurement
    # IO.inspect meta
    # IO.inspect opts
    # IO.puts ""

    {:noreply, state}
  end

  @impl true
  def handle_call(:get_totals_and_reset, _from, state) do
    {:reply, get_totals(state), @default_state}
  end

  # @spec report_telemetry(Map.t()) :: :ok
  # defp report_telemetry(state) do
  #   client =
  #     @client_states
  #     |> Map.new(fn cstate ->
  #       {cstate, state.client[cstate] |> Enum.count()}
  #     end)

  #   :telemetry.execute([:teiserver, :client], client, %{})
  #   :telemetry.execute([:teiserver, :battle], state.battle, %{})

  #   data = %{
  #     client: client,
  #     battle: state.battle,
  #     total_clients_connected: state.total_clients_connected
  #   }

  #   PubSub.broadcast(
  #     Teiserver.PubSub,
  #     "teiserver_telemetry",
  #     %{
  #       channel: "teiserver_telemetry",
  #       event: :data,
  #       data: data
  #     }
  #   )

  #   Teiserver.cache_put(:application_temp_cache, :telemetry_data, data)

  #   PubSub.broadcast(
  #     Teiserver.PubSub,
  #     "teiserver_public_stats",
  #     %{
  #       channel: "teiserver_public_stats",
  #       data: %{
  #         user_count: client.total,
  #         player_count: client.player,
  #         lobby_count: state.battle.total,
  #         in_progress_lobby_count: state.battle.in_progress,
  #         total_clients_connected: state.total_clients_connected
  #       }
  #     }
  #   )
  # end

  @spec get_totals(Map.t()) :: Map.t()
  defp get_totals(state) do
    # battles = Lobby.list_lobbies()
    # client_ids = Client.list_client_ids()

    # clients =
    #   client_ids
    #   |> Map.new(fn c -> {c, Client.get_client_by_id(c)} end)

    # # Battle stats
    # total_battles = Enum.count(battles)

    # battles_in_progress =
    #   battles
    #   |> Enum.filter(fn battle ->
    #     # If the host is in-game, the battle is in progress!
    #     host = clients[battle.founder_id]
    #     host != nil and host.in_game
    #   end)

    # # Client stats
    # {player_ids, spectator_ids, lobby_ids, menu_ids} =
    #   clients
    #   |> Enum.reduce({[], [], [], []}, fn {userid, client}, {player, spectator, lobby, menu} ->
    #     add_to =
    #       cond do
    #         client == nil -> nil
    #         client.bot == true -> nil
    #         client.lobby_id == nil -> :menu
    #         # Client is involved in a battle in some way
    #         # In this case they are not in a game, they are in a battle lobby
    #         client.in_game == false -> :lobby
    #         # User is in a game, are they a player or a spectator?
    #         client.player == false -> :spectator
    #         client.player == true -> :player
    #       end

    #     case add_to do
    #       nil -> {player, spectator, lobby, menu}
    #       :player -> {[userid | player], spectator, lobby, menu}
    #       :spectator -> {player, [userid | spectator], lobby, menu}
    #       :lobby -> {player, spectator, [userid | lobby], menu}
    #       :menu -> {player, spectator, lobby, [userid | menu]}
    #     end
    #   end)

    # lobby_memberships =
    #   clients
    #   |> Map.values()
    #   |> Enum.reject(fn
    #     %{lobby_id: lobby_id} -> lobby_id == nil
    #     _ -> true
    #   end)
    #   |> Enum.reduce(%{}, fn client, memberships ->
    #     new_lobby_membership = [client.userid | Map.get(memberships, client.lobby_id, [])]
    #     Map.put(memberships, client.lobby_id, new_lobby_membership)
    #   end)

    # login_queue_length = LoginThrottleServer.get_queue_length()

    # counters = state.counters

    # %{
    #   client: %{
    #     player: player_ids,
    #     spectator: spectator_ids,
    #     lobby: lobby_ids,
    #     menu: menu_ids,
    #     total: Enum.uniq(player_ids ++ spectator_ids ++ lobby_ids ++ menu_ids)
    #   },
    #   lobby_memberships: lobby_memberships,
    #   battle: %{
    #     total: total_battles,
    #     lobby: total_battles - Enum.count(battles_in_progress),
    #     in_progress: Enum.count(battles_in_progress),
    #     started: counters.matches_started,
    #     stopped: counters.matches_stopped
    #   },
    #   matchmaking: %{},
    #   server: %{
    #     users_connected: counters.users_connected,
    #     users_disconnected: counters.users_disconnected,
    #     bots_connected: counters.bots_connected,
    #     bots_disconnected: counters.bots_disconnected
    #   },
    #   total_clients_connected: Enum.count(clients),
    #   spring_server_messages_sent: state.spring_server_messages_sent,
    #   spring_server_batches_sent: state.spring_server_batches_sent,
    #   spring_client_messages_sent: state.spring_client_messages_sent,
    #   tachyon_server_messages_sent: state.tachyon_server_messages_sent,
    #   tachyon_server_batches_sent: state.tachyon_server_batches_sent,
    #   tachyon_client_messages_sent: state.tachyon_client_messages_sent,
    #   login_queue_length: login_queue_length
    #   # os_mon: get_os_mon_data()
    # }

    IO.puts "#{__MODULE__}:#{__ENV__.line}"
    IO.inspect "GET TOTALS"
    IO.puts ""
    %{}
  end

  # @spec get_os_mon_data :: map()
  # def get_os_mon_data() do
  #   process_counts = %{
  #     system_servers: Horde.Registry.count(Teiserver.ServerRegistry),
  #     throttle_servers: Horde.Registry.count(Teiserver.ThrottleRegistry),
  #     accolade_servers: Horde.Registry.count(Teiserver.AccoladesRegistry),
  #     consul_servers: Horde.Registry.count(Teiserver.ConsulRegistry),
  #     balancer_servers: Horde.Registry.count(Teiserver.BalancerRegistry),
  #     lobby_servers: Horde.Registry.count(Teiserver.LobbyRegistry),
  #     client_servers: Horde.Registry.count(Teiserver.ClientRegistry),
  #     party_servers: Horde.Registry.count(Teiserver.PartyRegistry),
  #     queue_wait_servers: Horde.Registry.count(Teiserver.QueueWaitRegistry),
  #     queue_match_servers: Horde.Registry.count(Teiserver.QueueMatchRegistry),
  #     managed_lobby_servers: Horde.Registry.count(Teiserver.LobbyPolicyRegistry)
  #   }

  #   process_counts =
  #     Map.merge(process_counts, %{
  #       beam_total: Process.list() |> Enum.count(),
  #       teiserver_total: process_counts |> Map.values() |> Enum.sum()
  #     })

  #   %{
  #     cpu_avg1: :cpu_sup.avg1(),
  #     cpu_avg5: :cpu_sup.avg5(),
  #     cpu_avg15: :cpu_sup.avg15(),
  #     cpu_nprocs: :cpu_sup.nprocs(),
  #     system_mem: :memsup.get_system_memory_data() |> Map.new(),
  #     processes: process_counts
  #   }
  # end

  # Startup
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:data], opts)
  end

  def handle_event(event, measure, meta, opts) do
    # Currently we have one genserver handling everything
    # I think a smart method would be to have a different genserver for each group
    # of events (in particular things like commands which will be more complex)
    # and then have the perist job just call each of them and do stuff

    # Example event
    # [:teiserver, :client, :new_connection], %{}, %{user_id: "f41c10c2-e8bf-4422-9584-4b03d49aa383"}, []

    # Angen.Telemetry.CollectorServer.handle_event([:teiserver, :client, :new_connection], %{}, %{user_id: "f41c10c2-e8bf-4422-9584-4b03d49aa383"}, [])

    send(Angen.Telemetry.CollectorServer, {:emit, event, measure, meta, opts})
  end

  @impl true
  def init(_opts) do
    {:ok, @default_state}
  end
end
