defmodule Angen.Logging.GraphMinuteLogsTask do
  @moduledoc false

  alias Angen.Helper.TimexHelper

  # @example_data %{
  #     "client" => %{"lobby" => 10, "menu" => 5, "total" => 15},
  #     "lobby" => %{"empty" => 10, "total" => 10},
  #     "server_processes" => %{
  #       "angen" => 607,
  #       "clients" => 15,
  #       "connections" => 582,
  #       "internal_servers" => 0,
  #       "lobbies" => 10
  #     },
  #     "telemetry_events" => %{
  #       "angen" => %{
  #         "protocol_command_count" => %{
  #           "auth/logged_in" => 106,
  #           "system/success" => 108
  #         },
  #         "protocol_command_time" => %{
  #           "auth/logged_in" => 13006086,
  #           "system/success" => 2027390
  #         }
  #       },
  #       "teiserver" => %{
  #         "client_disconnect_counter" => %{
  #           "down_message" => 8,
  #           "purposeful" => 108
  #         },
  #         "client_event_counter" => %{
  #           "added_connection" => 85,
  #           "new_connection" => 21
  #         },
  #         "lobby_event_counter" => %{}
  #       }
  #     },
  #     "totals" => %{"nodes" => 2, "unique_users" => 14}
  #   }

  @spec perform_clients(map, non_neg_integer()) :: list()
  def perform_clients(node_logs, chunk_size) do
    node_logs
    |> Enum.map(fn {node, logs} ->
      [node | extract_value(logs, chunk_size, ~w(client total))]
    end)
  end

  # @spec perform_matches(list, non_neg_integer()) :: list()
  # def perform_matches(logs, chunk_size) do
  #   [
  #     ["Matches lobby" | extract_value(logs, chunk_size, ~w(battle lobby))],
  #     ["Matches ongoing" | extract_value(logs, chunk_size, ~w(battle in_progress))]
  #   ]
  # end

  # @spec perform_matches_start_stop(list, non_neg_integer()) :: list()
  # def perform_matches_start_stop(logs, chunk_size) do
  #   [
  #     ["Matches started" | extract_value(logs, chunk_size, ~w(battle started))],
  #     ["Matches stopped" | extract_value(logs, chunk_size, ~w(battle stopped))]
  #   ]
  # end

  # @spec perform_user_connections(list, non_neg_integer()) :: list()
  # def perform_user_connections(logs, chunk_size) do
  #   [
  #     ["User Connects" | extract_value(logs, chunk_size, ~w(server users_connected))],
  #     ["User Disconnects" | extract_value(logs, chunk_size, ~w(server users_disconnected))]
  #   ]
  # end

  # @spec perform_bot_connections(list, non_neg_integer()) :: list()
  # def perform_bot_connections(logs, chunk_size) do
  #   [
  #     ["Bot Connects" | extract_value(logs, chunk_size, ~w(server bots_connected))],
  #     ["Bot Disconnects" | extract_value(logs, chunk_size, ~w(server bots_disconnected))]
  #   ]
  # end

  # @spec perform_combined_connections(list, non_neg_integer()) :: list()
  # def perform_combined_connections(logs, chunk_size) do
  #   user_connects = extract_value(logs, chunk_size, ~w(server users_connected))
  #   bot_connects = extract_value(logs, chunk_size, ~w(server bots_connected))

  #   user_disconnects = extract_value(logs, chunk_size, ~w(server users_disconnected))
  #   bot_disconnects = extract_value(logs, chunk_size, ~w(server bots_disconnected))

  #   connected =
  #     [user_connects, bot_connects]
  #     |> Enum.zip()
  #     |> Enum.map(fn {u, b} -> u + b end)

  #   disconnected =
  #     [user_disconnects, bot_disconnects]
  #     |> Enum.zip()
  #     |> Enum.map(fn {u, b} -> u + b end)

  #   [
  #     ["Connects" | connected],
  #     ["Disconnects" | disconnected]
  #   ]
  # end

  # # Gigabytes
  # @memory_div 1024 * 1024 * 1024

  # @spec perform_memory(list, non_neg_integer()) :: list()
  # def perform_memory(logs, chunk_size) do
  #   total =
  #     extract_value(logs, chunk_size, ~w(os_mon system_mem total_memory))
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   free =
  #     extract_value(logs, chunk_size, ~w(os_mon system_mem free_memory))
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   cached =
  #     extract_value(logs, chunk_size, ~w(os_mon system_mem cached_memory))
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   buffered =
  #     extract_value(logs, chunk_size, ~w(os_mon system_mem buffered_memory))
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   free_swap =
  #     extract_value(logs, chunk_size, ~w(os_mon system_mem free_swap))
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   total_swap =
  #     extract_value(logs, chunk_size, ~w(os_mon system_mem total_swap))
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   used =
  #     [total, free, cached, buffered]
  #     |> Enum.zip()
  #     |> Enum.map(fn {t, f, c, b} -> (t - (f + c + b)) |> NumberHelper.round(2) end)

  #   swap =
  #     [total_swap, free_swap]
  #     |> Enum.zip()
  #     |> Enum.map(fn {t, f} -> (t - f) |> NumberHelper.round(2) end)

  #   [
  #     # ["Total" | total],
  #     ["Used" | used],
  #     ["Buffered" | buffered],
  #     ["Cached" | cached],
  #     ["Swap" | swap]
  #   ]
  # end

  # @spec perform_memory_cost(list, non_neg_integer(), list) :: list()
  # def perform_memory_cost(logs, chunk_size, divisors) do
  #   total =
  #     extract_cost(logs, chunk_size, ~w(os_mon system_mem total_memory), divisors)
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   free =
  #     extract_cost(logs, chunk_size, ~w(os_mon system_mem free_memory), divisors)
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   cached =
  #     extract_cost(logs, chunk_size, ~w(os_mon system_mem cached_memory), divisors)
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   buffered =
  #     extract_cost(logs, chunk_size, ~w(os_mon system_mem buffered_memory), divisors)
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   free_swap =
  #     extract_cost(logs, chunk_size, ~w(os_mon system_mem free_swap), divisors)
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   total_swap =
  #     extract_cost(logs, chunk_size, ~w(os_mon system_mem total_swap), divisors)
  #     |> Enum.map(fn v -> (v / @memory_div) |> NumberHelper.round(2) end)

  #   used =
  #     [total, free, cached, buffered]
  #     |> Enum.zip()
  #     |> Enum.map(fn {t, f, c, b} -> (t - (f + c + b)) |> NumberHelper.round(2) end)

  #   swap =
  #     [total_swap, free_swap]
  #     |> Enum.zip()IO.puts "#{__MODULE__}:#{__ENV__.line}"
  #     ["Buffered" | buffered],
  #     ["Cached" | cached],
  #     ["Swap" | swap]
  #   ]
  # end

  # @spec perform_cpu_load(list, non_neg_integer()) :: list()
  # def perform_cpu_load(logs, chunk_size) do
  #   [
  #     ["CPU Load 1" | extract_value(logs, chunk_size, ~w(os_mon cpu_avg1))],
  #     ["CPU Load 5" | extract_value(logs, chunk_size, ~w(os_mon cpu_avg5))],
  #     ["CPU Load 15" | extract_value(logs, chunk_size, ~w(os_mon cpu_avg15))]
  #   ]
  # end

  # @spec perform_cpu_cost(list, non_neg_integer(), list) :: list()
  # def perform_cpu_cost(logs, chunk_size, divisors) do
  #   [
  #     ["CPU Load 1" | extract_cost(logs, chunk_size, ~w(os_mon cpu_avg1), divisors)],
  #     ["CPU Load 5" | extract_cost(logs, chunk_size, ~w(os_mon cpu_avg5), divisors)],
  #     ["CPU Load 15" | extract_cost(logs, chunk_size, ~w(os_mon cpu_avg15), divisors)]
  #   ]
  # end

  # @spec perform_server_messages(list, non_neg_integer()) :: list()
  # def perform_server_messages(logs, chunk_size) do
  #   [
  #     ["Server messages sent" | extract_value(logs, chunk_size, ~w(spring_server_messages_sent))]
  #   ]
  # end

  # @spec perform_server_messages_cost(list, non_neg_integer(), list) :: list()
  # def perform_server_messages_cost(logs, chunk_size, divisors) do
  #   [
  #     [
  #       "Server messages sent"
  #       | extract_cost(logs, chunk_size, ~w(spring_server_messages_sent), divisors)
  #     ]
  #   ]
  # end

  # @spec perform_client_messages(list, non_neg_integer()) :: list()
  # def perform_client_messages(logs, chunk_size) do
  #   [
  #     [
  #       "Client messages received"
  #       | extract_value(logs, chunk_size, ~w(spring_client_messages_sent))
  #     ]
  #   ]
  # end

  # @spec perform_client_messages_cost(list, non_neg_integer(), list()) :: list()
  # def perform_client_messages_cost(logs, chunk_size, divisors) do
  #   [
  #     [
  #       "Client messages received"
  #       | extract_cost(logs, chunk_size, ~w(spring_client_messages_sent), divisors)
  #     ]
  #   ]
  # end

  # @spec perform_system_process_counts(list, non_neg_integer()) :: list()
  # def perform_system_process_counts(logs, chunk_size) do
  #   [
  #     ["Throttles" | extract_value(logs, chunk_size, ~w(os_mon processes throttle_servers))],
  #     ["Accolades" | extract_value(logs, chunk_size, ~w(os_mon processes accolade_servers))],
  #     ["Lobbies" | extract_value(logs, chunk_size, ~w(os_mon processes lobby_servers))],
  #     ["Consuls" | extract_value(logs, chunk_size, ~w(os_mon processes consul_servers))],
  #     ["Balancers" | extract_value(logs, chunk_size, ~w(os_mon processes balancer_servers))],
  #     ["System" | extract_value(logs, chunk_size, ~w(os_mon processes system_servers))]
  #   ]
  # end

  # @spec perform_user_process_counts(list, non_neg_integer()) :: list()
  # def perform_user_process_counts(logs, chunk_size) do
  #   [
  #     ["Clients" | extract_value(logs, chunk_size, ~w(os_mon processes client_servers))],
  #     ["Parties" | extract_value(logs, chunk_size, ~w(os_mon processes party_servers))]
  #   ]
  # end

  # @spec perform_beam_process_counts(list, non_neg_integer()) :: list()
  # def perform_beam_process_counts(logs, chunk_size) do
  #   [
  #     ["Beam" | extract_value(logs, chunk_size, ~w(os_mon processes beam_total))],
  #     ["Angen" | extract_value(logs, chunk_size, ~w(os_mon processes teiserver_total))]
  #   ]
  # end

  @spec perform_axis_key(map, non_neg_integer()) :: list()
  def perform_axis_key(node_logs, chunk_size) do
    node_logs
    |> Enum.map(fn {_node, logs} ->
      logs
      |> Enum.chunk_every(chunk_size)
      |> Enum.map(fn [log | _] -> log.timestamp |> TimexHelper.date_to_str(format: :ymd_hms) end)
    end)
    |> List.flatten
    |> Enum.uniq
    |> Enum.sort
  end

  # def get_raw_player_count(logs, chunk_size) do
  #   %{
  #     "Total" => extract_value(logs, chunk_size, ~w(total_clients_connected)),
  #     "People" => extract_value(logs, chunk_size, ~w(client total), &Enum.count/1),
  #     "Players" => extract_value(logs, chunk_size, ~w(client player), &Enum.count/1)
  #   }
  # end

  defp extract_value(logs, 1, path) do
    logs
    |> Enum.map(fn log ->
      get_in(log.data, path) || 0
    end)
  end

  defp extract_value(logs, chunk_size, path, func \\ fn x -> x end) do
    logs
    |> Enum.chunk_every(chunk_size)
    |> Enum.map(fn chunk ->
      result =
        chunk
        |> Enum.map(fn log ->
          get_in(log.data, path) |> func.() || 0
        end)
        |> Enum.sum()

      result / chunk_size
    end)
  end

  # defp extract_cost(logs, 1, path, divisors) do
  #   Enum.zip(logs, divisors)
  #   |> Enum.map(fn {log, d} ->
  #     (get_in(log.data, path) || 0) / max(d, 1)
  #   end)
  # end

  # defp extract_cost(logs, chunk_size, path, divisors, func \\ fn x -> x end) do
  #   Enum.zip(logs, divisors)
  #   |> Enum.chunk_every(chunk_size)
  #   |> Enum.map(fn chunk ->
  #     result =
  #       chunk
  #       |> Enum.map(fn {log, d} ->
  #         (get_in(log.data, path) |> func.() || 0) / max(d, 1)
  #       end)
  #       |> Enum.sum()

  #     NumberHelper.round(result / chunk_size, 2)
  #   end)
  # end

  @spec round(number(), non_neg_integer()) :: integer() | float()
  def round(value, decimal_places) do
    dp_mult = :math.pow(10, decimal_places)
    round(value * dp_mult) / dp_mult
  end
end
