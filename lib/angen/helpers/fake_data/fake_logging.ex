defmodule Angen.FakeData.FakeLogging do
  @moduledoc false

  alias Angen.Logging
  import Logging.PersistServerMinuteTask, only: [add_total_key: 1, add_total_key: 3]

  import Angen.Helpers.FakeDataHelper,
    only: [
      rand_int_sequence: 4,
      rand_int: 3,
      valid_user_ids: 1,
      valid_user_ids: 2,
      random_time_in_day: 1
    ]

  def make_logs(config) do
    # We only want a few days of minute logs
    0..min(config.days, config.detail_days)
    |> Enum.each(fn day ->
      date = Timex.today() |> Timex.shift(days: -day)

      make_server_minutes(Map.put(config, :node, "node1"), date)
      make_server_minutes(Map.put(config, :node, "node2"), date)
      make_server_minutes(Map.put(config, :node, "all"), date)
      # combine_minutes(config, date)
    end)

    make_server_days(config)

    # For the days with detail we can generate them using the actual data
    0..min(config.days, config.detail_days)
    |> Enum.each(fn _ ->
      Angen.Logging.PersistServerDayTask.perform(:ok)
    end)

    # Persist Week, Month, Quarter and Year
    0..round(config.days / 7)
    |> Enum.each(fn _ ->
      Logging.PersistServerWeekTask.perform(:ok)
      Logging.PersistServerMonthTask.perform(:ok)
      Logging.PersistServerQuarterTask.perform(:ok)
      Logging.PersistServerYearTask.perform(:ok)
    end)

    make_audit_logs(config)
  end

  # defp combine_minutes(_config, date) do
  #   0..1439
  #   |> Enum.each(fn m ->
  #     timestamp =
  #       date
  #       |> Timex.to_datetime()
  #       |> Timex.shift(minutes: m)
  #       |> Timex.set(microsecond: 0, second: 0)

  #     Logging.CombineServerMinuteTask.perform(%{now: timestamp})
  #   end)
  # end

  defp make_server_minutes(config, date) do
    max_users = Enum.count(valid_user_ids(date))

    {new_logs, _} =
      0..1439
      |> Enum.map_reduce(%{}, fn m, last_data ->
        timestamp =
          date
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
    |> Ecto.Multi.insert_all(:insert_all, Logging.ServerMinuteLog, new_logs)
    |> Angen.Repo.transaction()
  end

  defp make_minute_data(config, last_minute) do
    mu = config.max_users

    client =
      %{
        "bot" => rand_int(0, mu / 5, get_in(last_minute, ~w(client bot))),
        "menu" => rand_int(0, mu / 2, 10),
        "lobby" => rand_int(0, mu / 2, 10),
        "spectator" => rand_int(0, mu / 2, 10),
        "player" => rand_int(0, mu / 3, 10)
      }
      |> add_bot_totals

    lobby =
      %{
        "in_progress" => rand_int(0, mu / 2, 10),
        "empty" => rand_int(0, mu / 2, 10),
        "setup" => rand_int(0, mu / 2, 10)
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
            "auth/logged_in" => rand_int(mu, mu * 4, nil),
            "connections/client_updated" => rand_int(mu * 12, mu * 4, nil),
            "connections/youare" => rand_int(mu, mu * 4, nil),
            "lobby/opened" => rand_int(mu, mu * 4, nil),
            "system/failure" => rand_int(mu, mu * 4, nil),
            "system/success" => rand_int(mu, mu * 4, nil)
          },
          "protocol_command_time" => %{
            "auth/logged_in" => rand_int(1024, 64_000, nil),
            "connections/client_updated" => rand_int(1024, 64_000, nil),
            "connections/youare" => rand_int(1024, 64_000, nil),
            "lobby/opened" => rand_int(1024, 64_000, nil),
            "system/failure" => rand_int(1024, 64_000, nil),
            "system/success" => rand_int(1024, 64_000, nil)
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

  def make_server_days(config) do
    # Now do much longer for days
    {new_logs, _} =
      config.days..config.detail_days
      |> Enum.map_reduce(%{}, fn day, last_data ->
        date = Timex.today() |> Timex.shift(days: -day)
        max_users = Enum.count(valid_user_ids(date))

        data = make_day_data(Map.merge(config, %{max_users: max_users, date: date}), last_data)

        {%{
           date: date,
           data: data
         }, data}
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Logging.ServerDayLog, new_logs)
    |> Angen.Repo.transaction()
  end

  defp make_day_data(config, last_day) do
    accounts_created =
      Enum.count(valid_user_ids(config.date, config.date |> Timex.shift(days: 1)))

    minutes =
      %{
        "lobby" =>
          rand_int(
            config.max_users * 20,
            config.max_users * 600,
            get_in(last_day, ~w(minutes lobby))
          ),
        "menu" =>
          rand_int(
            config.max_users * 20,
            config.max_users * 600,
            get_in(last_day, ~w(minutes menu))
          ),
        "player" =>
          rand_int(
            config.max_users * 20,
            config.max_users * 600,
            get_in(last_day, ~w(minutes player))
          ),
        "spectator" =>
          rand_int(
            config.max_users * 20,
            config.max_users * 600,
            get_in(last_day, ~w(minutes spectator))
          ),
        "bot" =>
          rand_int(
            config.max_users * 20,
            config.max_users * 600,
            get_in(last_day, ~w(minutes bot))
          )
      }
      |> add_bot_totals

    %{
      "average_user_counts" => %{
        "lobby" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "menu" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "player" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "spectator" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "total_inc_bot" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24),
        "total_non_bot" => rand_int_sequence(config.max_users / 10, config.max_users / 3, 0, 24)
      },
      "minutes" => minutes,
      "peak_user_counts" =>
        %{
          "bot" =>
            rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts bot))),
          "lobby" =>
            rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts lobby))),
          "menu" =>
            rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts menu))),
          "player" =>
            rand_int(
              10,
              config.max_users / 3,
              get_in(last_day, ~w(stats peak_user_counts player))
            ),
          "spectator" =>
            rand_int(
              10,
              config.max_users / 3,
              get_in(last_day, ~w(stats peak_user_counts spectator))
            ),
          "total" =>
            rand_int(10, config.max_users / 3, get_in(last_day, ~w(stats peak_user_counts total)))
        }
        |> add_bot_totals,
      "stats" => %{
        "accounts_created" => accounts_created,
        "unique_users" =>
          rand_int(
            config.max_users / 10,
            config.max_users,
            get_in(last_day, ~w(stats unique_users))
          ),
        "unique_players" =>
          rand_int(
            config.max_users / 12,
            config.max_users / 1.5,
            get_in(last_day, ~w(stats unique_users))
          )
      },
      "telemetry_events" => %{
        "simple_clientapp" => %{
          "connected" =>
            rand_int(
              config.max_users / 6,
              config.max_users,
              get_in(last_day, ~w(telemetry simple_clientapp connected))
            ),
          "disconnected" =>
            rand_int(
              config.max_users / 6,
              config.max_users,
              get_in(last_day, ~w(telemetry simple_clientapp disconnected))
            )
        },
        "simple_lobby" => %{
          "cycle" =>
            rand_int(
              config.max_users * 4,
              config.max_users * 12,
              get_in(last_day, ~w(telemetry simple_clientapp cycle))
            )
        }
      }
    }
  end

  defp add_bot_totals(m) do
    m
    |> add_total_key("total_non_bot", ["bot"])
    |> add_total_key("total_inc_bot", ["total_non_bot"])
  end

  @audit_log_reasons ["Failed login", "Permissions failure", "Account updated"]

  defp make_audit_logs(config) do
    log_data =
      0..(config.days - 1)
      |> Enum.map(fn day ->
        date = Timex.today() |> Timex.shift(days: -day)
        user_ids = valid_user_ids(date)

        0..3
        |> Enum.map(fn _ ->
          random_time = random_time_in_day(date)

          %{
            action: Enum.random(@audit_log_reasons),
            details: %{key: "value"},
            ip:
              "#{:rand.uniform(600) + 270}.#{:rand.uniform(256)}.#{:rand.uniform(256)}.#{:rand.uniform(256)}",
            user_id: Enum.random(user_ids),
            inserted_at: random_time,
            updated_at: random_time
          }
        end)
      end)
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Teiserver.Logging.AuditLog, log_data)
    |> Angen.Repo.transaction()
  end
end
