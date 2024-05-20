defmodule Angen.Logging.PersistServerMinuteTask do
  @moduledoc """
  A task used to persist a `Angen.Logging.ServerMinuteLog`; [(can be extended)](config.html#logging_post_server_minute_collect).
  """
  use Oban.Worker, queue: :logging

  alias Angen.{Logging, Telemetry}
  alias Teiserver.{Connections, Game}

  # Angen.Logging.PersistServerMinuteTask.perform(%{})

  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(_) do
    if Angen.startup_complete?() do
      now = Timex.now() |> Timex.set(microsecond: 0, second: 0)

      case Logging.get_server_minute_log(now, Teiserver.get_node_name()) do
        nil ->
          case perform_telemetry_persist(now) do
            {:ok, _log} ->
              :ok

            v ->
              raise v

          end

        _ ->
          :ok
      end
    end

    :ok
  end

  @spec perform_telemetry_persist(DateTime.t()) :: any
  def perform_telemetry_persist(timestamp) do
    data = %{
      client: get_client_states(),
      lobby: get_lobby_states(),
      server_processes: get_server_details(),
      os: get_os_details(),
      telemetry_events: get_telemetry_events()
    }

    Logging.create_server_minute_log(%{
      timestamp: timestamp,
      node: Teiserver.get_node_name(),
      data: data
    })
  end


  @spec get_client_states() :: map()
  def get_client_states() do
    Connections.list_local_client_ids()
    |> Enum.map(fn user_id -> Connections.get_client(user_id) end)
    |> Enum.group_by(fn client ->
      case client do
        nil -> nil
        %{bot?: true} -> :bot
        %{lobby_id: nil} -> :menu

        # Client is involved in a battle in some way
        # In this case they are not in a game, they are in a battle lobby
        %{in_game?: false} -> :lobby

        # CLient is in a game, are they a player or a spectator?
        %{player?: false} -> :spectator
        %{player?: true} -> :player
      end
    end,
    fn _client ->
      1
    end)
    |> Map.drop([nil])
    |> Map.new(fn {key, values} ->
      {key, Enum.count(values)}
    end)
    |> add_total_key
  end

  @spec get_lobby_states() :: map()
  def get_lobby_states() do
    Game.list_local_lobby_ids()
    |> Enum.map(fn lobby_id -> Game.get_lobby(lobby_id) end)
    |> Enum.group_by(fn lobby ->
      case lobby do
        nil -> nil
        %{match_ongoing?: true} -> :in_progress
        %{players: []} -> :empty
        true -> :setup
      end
    end,
    fn _lobby ->
      1
    end)
    |> Map.drop([nil])
    |> Map.new(fn {key, values} ->
      {key, Enum.count(values)}
    end)
    |> add_total_key
  end

  @doc """
  Generates stats about this specific node from the Teiserver/Angen application
  """
  @spec get_server_details() :: map()
  def get_server_details() do
    %{
      connections: Registry.count(Angen.LocalConnectionRegistry),
      clients: Registry.count(Teiserver.LocalClientRegistry),
      lobbies: Registry.count(Teiserver.LocalLobbyRegistry),
      internal_servers: Registry.count(Teiserver.LocalServerRegistry)
    }
    |> add_total_key(:angen)
    |> Map.put(:beam_total, Process.list() |> Enum.count())
  end

  @doc """
  Gets details about this specific node from the OS
  """
  @spec get_os_details() :: map()
  def get_os_details() do
    %{
      cpu_avg1: :cpu_sup.avg1(),
      cpu_avg5: :cpu_sup.avg5(),
      cpu_avg15: :cpu_sup.avg15(),
      cpu_nprocs: :cpu_sup.nprocs(),
      # cpu_per_core: cpu_per_core |> Map.new(),
      # disk: disk |> Map.new(),
      system_mem: :memsup.get_system_memory_data() |> Map.new()
    }
  end

  @spec get_telemetry_events() :: map()
  def get_telemetry_events() do
    Telemetry.TelemetryLib.get_all_totals(true)
  end

  # Given a map where the values are integers, add them up and create a new key `:total`
  # with the sum of said values
  @spec add_total_key(map, atom) :: map
  defp add_total_key(m, key \\ :total) do
    total = m |> Map.values |> Enum.sum()
    Map.put(m, key, total)
  end
end
