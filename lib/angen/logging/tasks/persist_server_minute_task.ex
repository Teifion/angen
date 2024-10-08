defmodule Angen.Logging.PersistServerMinuteTask do
  @moduledoc false
  alias Angen.Logging.ServerMinuteLog
  use Oban.Worker, queue: :logging

  alias Angen.{Logging, Telemetry}
  alias Teiserver.{Connections, Game}

  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(args) do
    now = args[:now] || DateTime.utc_now() |> DateTime.truncate(:second)

    case Logging.get_server_minute_log(now, Teiserver.get_node_name()) do
      nil ->
        {:ok, _log} = perform_telemetry_persist(now)

      _ ->
        :ok
    end
  end

  @spec perform_telemetry_persist(DateTime.t()) :: {:ok, ServerMinuteLog}
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
    |> Enum.group_by(
      fn client ->
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
      end
    )
    |> Map.drop([nil])
    |> Map.new(fn {key, values} ->
      {key, Enum.count(values)}
    end)
    |> add_total_key(:total_non_bot, [:bot])
    |> add_total_key(:total_inc_bot, [:total_non_bot])
  end

  @spec get_lobby_states() :: map()
  def get_lobby_states() do
    Game.list_local_lobby_ids()
    |> Enum.map(fn lobby_id -> Game.get_lobby(lobby_id) end)
    |> Enum.group_by(
      fn lobby ->
        case lobby do
          nil -> nil
          %{match_ongoing?: true} -> :in_progress
          %{players: []} -> :empty
          _ -> :setup
        end
      end,
      fn _lobby ->
        1
      end
    )
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

  @doc """
  Given a map where the values are integers, add them up and create a new key `:total`
  with the sum of said values.

  Takes a map of values but can optionally also take:
  - key: The key which the total value is placed
  - dropping: keys which are ignored for the calculation of the total
  """
  @spec add_total_key(map, atom | String.t(), list) :: map
  def add_total_key(m, key \\ :total, dropping \\ []) do
    total = m |> Map.drop(dropping) |> Map.values() |> Enum.sum()
    Map.put(m, key, total)
  end
end
