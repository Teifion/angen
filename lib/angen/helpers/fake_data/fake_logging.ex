defmodule Angen.FakeData.FakeLogging do
  @moduledoc false

  alias Angen.Logging
  import Angen.Logging.PersistServerMinuteTask, only: [add_total_key: 1, add_total_key: 3]
  import Mix.Tasks.Angen.Fakedata, only: [rand_int_sequence: 4, rand_int: 3, valid_userids: 1]

  def make_logs(config) do
    # We only want a few days of minute logs
    Range.new(0, min(config.days, 3))
    |> Enum.each(fn day ->
      date = Timex.today() |> Timex.shift(days: -day)

      make_server_minutes(Map.put(config, :node, "node1"), date)
      make_server_minutes(Map.put(config, :node, "node2"), date)
      combine_minutes(config, date)
    end)

    make_server_days(config)

    # Persist Week, Month, Quarter and Year
    # Range.new(0, config.days)
    # |> Enum.each(fn _ ->

    # end)
  end

  defp combine_minutes(_config, date) do
    Range.new(0, 1439)
    |> Enum.each(fn m ->
      timestamp = date
        |> Timex.to_datetime()
        |> Timex.shift(minutes: m)
        |> Timex.set(microsecond: 0, second: 0)

      Angen.Logging.CombineServerMinuteTask.perform(%{now: timestamp})
    end)
  end

  defp make_server_minutes(config, date) do
    max_users = Enum.count(valid_userids(date))

    {new_logs, _} = Range.new(0, 1439)
    |> Enum.map_reduce(%{}, fn (m, last_data) ->
      timestamp = date
        |> Timex.to_datetime()
        |> Timex.shift(minutes: m)
        |> Timex.set(microsecond: 0, second: 0)

      data = make_minute_data(Map.put(config, :max_users, max_users), last_data)

      {%{
        timestamp: timestamp,
        node: config.node,
        data: data
      }, data}
    end)

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Angen.Logging.ServerMinuteLog, new_logs)
    |> Angen.Repo.transaction()
  end

  defp make_minute_data(config, last_minute) do
    client = %{
      "bot" => rand_int(0, config.max_users / 5, get_in(last_minute, ~w(client bot))),
      "menu" => rand_int(0, config.max_users / 2, 10),
      "lobby" => rand_int(0, config.max_users / 2, 10),
      "spectator" => rand_int(0, config.max_users / 2, 10),
      "player" => rand_int(0, config.max_users / 3, 10),
    }
    |> add_total_key(:total_non_bot, [:bot])
    |> add_total_key(:total_bot, [:non_bot])

    lobby = %{
      "in_progress" => rand_int(0, config.max_users / 2, 10),
      "empty" => rand_int(0, config.max_users / 2, 10),
      "setup" => rand_int(0, config.max_users / 2, 10),
    }
    |> add_total_key()

    %{
      "client" => client,
      "lobby" => lobby,
      "os" => %{
        "cpu_avg1" => 56,
        "cpu_avg15" => 18,
        "cpu_avg5" => 46,
        "cpu_nprocs" => 155,
        "system_mem" => %{
          "available_memory" => rand_int(64_000, 256_000_000, nil),
          "buffered_memory" => rand_int(64_000, 256_000_000, nil),
          "cached_memory" => rand_int(64_000, 256_000_000, nil),
          "free_memory" => rand_int(64_000, 256_000_000, nil),
          "free_swap" => rand_int(64_000, 256_000_000, nil),
          "system_total_memory" => rand_int(64_000, 256_000_000, nil),
          "total_memory" => rand_int(64_000, 256_000_000, nil),
          "total_swap" => rand_int(64_000, 256_000_000, nil)
        }
      },
      "server_processes" => %{
        "angen" => 63,
        "beam_total" => 943,
        "clients" => 5,
        "connections" => 55,
        "internal_servers" => 0,
        "lobbies" => 3
      },
      "telemetry_events" => %{
        "angen" => %{
          "protocol_command_count" => %{
            "auth/logged_in" => 49,
            "connections/client_updated" => 3,
            "connections/youare" => 6,
            "lobby/opened" => 2,
            "system/failure" => 6,
            "system/success" => 41
          },
          "protocol_command_time" => %{
            "auth/logged_in" => 7091908,
            "connections/client_updated" => 42330,
            "connections/youare" => 479896,
            "lobby/opened" => 26161,
            "system/failure" => 211741,
            "system/success" => 1704927
          }
        },
        "teiserver" => %{
          "client_disconnect_counter" => %{"purposeful" => 41},
          "client_event_counter" => %{
            "added_connection" => 38,
            "new_connection" => 11,
            "updated" => 2
          },
          "lobby_event_counter" => %{"cycle" => 2}
        }
      }
    }
  end

  defp make_server_days(config) do
    # Now do much longer for days
    {new_logs, _} = Range.new(config.days, 0)
    |> Enum.map_reduce(%{}, fn (day, last_data) ->
      date = Timex.today() |> Timex.shift(days: -day)
      max_users = Enum.count(valid_userids(date))

      data = make_day_data(Map.merge(config, %{max_users: max_users, date: date}), last_data)

      {%{
        date: date,
        data: data
      }, data}
    end)

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Angen.Logging.ServerDayLog, new_logs)
    |> Angen.Repo.transaction()
  end

  defp make_day_data(config, last_day) do
    accounts_created = Teiserver.Account.list_users(
      where: [
        inserted_after: Timex.to_datetime(config.date),
        inserted_before: Timex.to_datetime(config.date |> Timex.shift(days: 1))
      ],
      select: [:id]
    )
    |> Enum.count

    %{
      "average_user_counts" => %{
        "lobby" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "menu" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "player" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "spectator" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "total" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24)
      },
      "minutes" => add_total_key(%{
        "lobby" => rand_int(config.max_users * 20, config.max_users * 600, get_in(last_day, ~w(minutes lobby))),
        "menu" => rand_int(config.max_users * 20, config.max_users * 600, get_in(last_day, ~w(minutes menu))),
        "player" => rand_int(config.max_users * 20, config.max_users * 600, get_in(last_day, ~w(minutes player))),
        "spectator" => rand_int(config.max_users * 20, config.max_users * 600, get_in(last_day, ~w(minutes spectator)))
      }, "total", []),
      "peak_user_counts" => %{
        "lobby" => rand_int_sequence(config.max_users / 10, config.max_users / 4, 0, 24),
        "menu" => rand_int_sequence(config.max_users / 10, config.max_users / 4, 0, 24),
        "player" => rand_int_sequence(config.max_users / 10, config.max_users / 4, 0, 24),
        "spectator" => rand_int_sequence(config.max_users / 10, config.max_users / 4, 0, 24),
        "total" => rand_int_sequence(config.max_users / 10, config.max_users / 4, 0, 24)
      },
      "peak_user_counts" => %{
        "bot" => rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts bot))),
        "lobby" => rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts lobby))),
        "menu" => rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts menu))),
        "player" => rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts player))),
        "spectator" => rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts spectator))),
        "total" => rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts total))),
      },
      "stats" => %{
        "accounts_created" => accounts_created,
        "unique_users" => rand_int(config.max_users / 10, config.max_users, get_in(last_day, ~w(stats unique_users))),
        "unique_players" => rand_int(config.max_users / 12, config.max_users / 1.5, get_in(last_day, ~w(stats unique_users))),
      }
    }
  end
end
