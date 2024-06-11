defmodule Angen.Logging.PersistServerDayTask do
  @moduledoc false
  alias Credo.Code.Charlists
  use Oban.Worker, queue: :logging

  alias Angen.{Repo, Logging, Telemetry}
  alias Angen.Logging.ServerMinuteLogLib

  # Minutes
  @segment_length 60
  @segment_count div(1440, @segment_length) - 1

  @log_keep_days 30

  @client_states ~w(lobby bot menu player spectator total_non_bot total_inc_bot)a

  # [] List means 1 hour segments
  # %{} Dict means total for the day for that key
  # 0 Integer means sum or average
  @empty_log %{
    # Average lobby counts per segment
    lobbies: %{
      in_progress: [],
      setup: [],
      empty: [],
      total: []
    },

    # Daily totals
    stats: %{
      accounts_created: 0,
      unique_users: 0,
      unique_players: 0
    },

    # Total number of minutes spent doing that across all players that day
    minutes: %{
      player: 0,
      spectator: 0,
      lobby: 0,
      menu: 0,
      bot: 0,
      total_non_bot: 0,
      total_inc_bot: 0
    },

    # The number of minutes users (combined) spent in that state during the segment
    average_user_counts: %{
      bot: [],
      player: [],
      spectator: [],
      lobby: [],
      menu: [],
      total_non_bot: [],
      total_inc_bot: []
    },
    peak_user_counts: %{
      bot: [],
      player: [],
      spectator: [],
      lobby: [],
      menu: [],
      total_non_bot: [],
      total_inc_bot: []
    }
  }

  @empty_segment %{
    # Used to make calculating the end of day stats easier, this will not appear in the final result
    tmp_reduction: %{
      unique_users: [],
      unique_players: []
    },

    # Daily totals
    stats: %{
      accounts_created: 0,
      unique_users: 0,
      unique_players: 0
    },

    # Total number of minutes spent doing that across all players that day
    minutes: %{
      bot: 0,
      player: 0,
      spectator: 0,
      lobby: 0,
      menu: 0,
      total_non_bot: 0,
      total_inc_bot: 0
    },

    # The number of minutes users (combined) spent in that state during the segment
    average_user_counts: %{
      bot: 0,
      player: 0,
      spectator: 0,
      lobby: 0,
      menu: 0,
      total_non_bot: 0,
      total_inc_bot: 0
    },
    peak_user_counts: %{
      bot: 0,
      player: 0,
      spectator: 0,
      lobby: 0,
      menu: 0,
      total_non_bot: 0,
      total_inc_bot: 0
    }
  }


  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(_) do
    last_date = Logging.get_last_server_day_log_date()

    date =
      if last_date == nil do
        Angen.Logging.get_first_server_minute_datetime()
        |> Timex.to_date()
      else
        last_date
        |> Timex.shift(days: 1)
      end

    if Timex.compare(date, Timex.today()) == -1 do
      do_perform(date, cleanup: true)

      new_date = Timex.shift(date, days: 1)

      if Timex.compare(new_date, Timex.today()) == -1 do
        %{}
        |> Angen.Logging.PersistServerDayTask.new()
        |> Oban.insert()
      end
    end

    :ok
  end

  @spec do_perform(Date.t(), boolean()) :: :ok
  def do_perform(date, cleanup) do
    date = Timex.to_date(date)

    data =
      0..@segment_count
      |> Enum.reduce(@empty_log, fn segment_number, segment ->
        logs = get_logs(date, segment_number, "all")

        extend_segment(segment, logs)
      end)
      |> calculate_day_statistics(date, "all")
      |> add_telemetry(date, "all")

    if cleanup do
      clean_up_logs(date)
    end

    # Delete old log if it exists
    Logging.server_day_log_query(
      where: [date: date],
      limit: :infinity
    )
    |> Repo.delete_all()

    Logging.create_server_day_log(%{
      date: date,
      data: data
    })

    :ok
  end

  # Angen.Logging.PersistServerDayTask.today_so_far()
  def today_so_far(node \\ "all") do
    date = Timex.today()

    0..@segment_count
    |> Enum.reduce(@empty_log, fn segment_number, segment ->
      logs = get_logs(date, segment_number, node)
      extend_segment(segment, logs)
    end)
    |> calculate_day_statistics(date, node)
    |> add_telemetry(date, node)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end

  @spec get_logs(Date.t(), non_neg_integer(), String.t()) :: list()
  defp get_logs(date, segment_number, node) do
    start_time =
      Timex.shift(date |> Timex.to_datetime(), minutes: segment_number * @segment_length)

    end_time =
      Timex.shift(date |> Timex.to_datetime(), minutes: (segment_number + 1) * @segment_length)

    Logging.list_server_minute_logs(
      search: [
        after: start_time,
        before: end_time,
        node: node
      ],
      select: [:data],
      limit: :infinity
    )
    |> Enum.map(fn l -> l.data end)
  end

  # Given an existing segment and a batch of logs, calculate the segment and add them together
  defp extend_segment(segment, logs) do
    extend = calculate_segment_parts(logs)


    %{
      # Daily totals
      stats: %{
        accounts_created: 0,
        unique_users: 0,
        unique_players: 0
      },

      # Total number of minutes spent doing that across all players that day
      minutes: %{
        player: segment.minutes.player + extend.minutes.player,
        spectator: segment.minutes.spectator + extend.minutes.spectator,
        lobby: segment.minutes.lobby + extend.minutes.lobby,
        menu: segment.minutes.menu + extend.minutes.menu,
        bot: segment.minutes.bot + extend.minutes.bot,
        total_non_bot: segment.minutes.total_non_bot + extend.minutes.total_non_bot,
        total_inc_bot: segment.minutes.total_inc_bot + extend.minutes.total_inc_bot
      },

      # The number of minutes users (combined) spent in that state during the segment
      average_user_counts: %{
        player: segment.average_user_counts.player ++ [extend.average_user_counts.player],
        spectator:
          segment.average_user_counts.spectator ++ [extend.average_user_counts.spectator],
        lobby: segment.average_user_counts.lobby ++ [extend.average_user_counts.lobby],
        menu: segment.average_user_counts.menu ++ [extend.average_user_counts.menu],
        bot: segment.average_user_counts.bot ++ [extend.average_user_counts.bot],
        total_non_bot: segment.average_user_counts.total_non_bot ++ [extend.average_user_counts.total_non_bot],
        total_inc_bot: segment.average_user_counts.total_inc_bot ++ [extend.average_user_counts.total_inc_bot]
      },
      peak_user_counts: %{
        player: segment.peak_user_counts.player ++ [extend.peak_user_counts.player],
        spectator: segment.peak_user_counts.spectator ++ [extend.peak_user_counts.spectator],
        lobby: segment.peak_user_counts.lobby ++ [extend.peak_user_counts.lobby],
        menu: segment.peak_user_counts.menu ++ [extend.peak_user_counts.menu],
        bot: segment.peak_user_counts.bot ++ [extend.peak_user_counts.bot],
        total_non_bot: segment.peak_user_counts.total_non_bot ++ [extend.peak_user_counts.total_non_bot],
        total_inc_bot: segment.peak_user_counts.total_inc_bot ++ [extend.peak_user_counts.total_inc_bot]
      }
    }
  end

  # Given a list of logs, calculate a segment for them
  defp calculate_segment_parts([]), do: @empty_segment

  defp calculate_segment_parts(logs) do
    count = Enum.count(logs)

    empty_user_maps = %{
      total_non_bot: 0,
      total_inc_bot: 0,
      bot: 0,
      player: 0,
      spectator: 0,
      lobby: 0,
      menu: 0
    }

    # Generate a map counting `users * minutes` across this segment
    user_maps =
      logs
      |> Enum.reduce(empty_user_maps, fn log, acc ->
        %{
          total_non_bot: acc.bot + Map.get(log["client"], "total_non_bot", 0),
          total_inc_bot: acc.bot + Map.get(log["client"], "total_inc_bot", 0),
          bot: acc.bot + Map.get(log["client"], "bot", 0),
          player: acc.player + Map.get(log["client"], "player", 0),
          spectator: acc.spectator + Map.get(log["client"], "spectator", 0),
          lobby: acc.lobby + Map.get(log["client"], "lobby", 0),
          menu: acc.menu + Map.get(log["client"], "menu", 0)
        }
      end)

    %{
      # Daily totals
      stats: %{
        accounts_created: 0,
        unique_users: 0,
        unique_players: 0
      },

      # Total number of minutes spent doing that across all players that day
      minutes: user_maps,

      # The number of minutes users (combined) spent in that state during the segment
      average_user_counts: %{
        bot: sum_counts(logs, ~w(client bot)) / count,
        player: sum_counts(logs, ~w(client player)) / count,
        spectator: sum_counts(logs, ~w(client spectator)) / count,
        lobby: sum_counts(logs, ~w(client lobby)) / count,
        menu: sum_counts(logs, ~w(client menu)) / count,
        total_inc_bot: sum_counts(logs, ~w(client total_inc_bot)) / count,
        total_non_bot: sum_counts(logs, ~w(client total_non_bot)) / count
      },
      peak_user_counts: %{
        bot: max_counts(logs, ~w(client bot)),
        player: max_counts(logs, ~w(client player)),
        spectator: max_counts(logs, ~w(client spectator)),
        lobby: max_counts(logs, ~w(client lobby)),
        menu: max_counts(logs, ~w(client menu)),
        total_inc_bot: max_counts(logs, ~w(client total_inc_bot)),
        total_non_bot: max_counts(logs, ~w(client total_non_bot))
      }
    }
  end

  defp add_telemetry(data, date, _node) do
    end_of_day = Timex.shift(date, days: 1)

    Map.put(data, :telemetry, %{
      simple_clientapp: Telemetry.simple_clientapp_events_summary(after: date, before: end_of_day),

      simple_lobby: Telemetry.simple_lobby_events_summary(after: date, before: end_of_day)
    })
  end

  # Given a day log, calculate the end of day stats
  defp calculate_day_statistics(data, date, _node) do
    tomorrow = Timex.shift(date, days: 1)

    accounts_created =
      Teiserver.Account.user_query(
        where: [
          inserted_after: date |> Timex.to_datetime(),
          inserted_before: tomorrow |> Timex.to_datetime(),
          smurf_of: false,
          not_has_group: "guest",
          not_has_restriction: "login"
        ],
        limit: :infinity
      )
      |> Repo.aggregate(:count)

    unique_users = get_unique_users(date)

    # Need to query match membership to get this
    unique_players = -1

    # Calculate peak users across the day
    peak_user_counts =
      @client_states
      |> Map.new(fn state_key ->
        counts = Map.get(data.peak_user_counts, state_key, [0])
        {state_key, Enum.max(counts)}
      end)

    stats = %{
      unique_users: unique_users,
      unique_players: unique_players,
      accounts_created: accounts_created,
    }

    data
    |> put_in(~w(stats)a, stats)
    |> put_in(~w(peak_user_counts)a, peak_user_counts)
    |> Map.delete(:tmp_reduction)
  end

  @spec clean_up_logs(Date.t()) :: :ok
  defp clean_up_logs(date) do
    # Clean up all minute logs older than X days
    before_timestamp =
      Timex.shift(date, days: -@log_keep_days)
      |> Timex.to_datetime()

    query = """
      DELETE FROM #{Angen.Logging.ServerMinuteLog.__schema__(:source)} WHERE timestamp < $1
    """
    Ecto.Adapters.SQL.query!(Angen.Repo, query, [before_timestamp])
  end

  # defp concatenate_lists(items, path) do
  #   items
  #   |> Enum.reduce([], fn row, acc ->
  #     acc ++ (get_in(row, path) || [])
  #   end)
  # end

  defp max_counts(items, path) do
    items
    |> Enum.reduce(0, fn row, acc ->
      max(acc, (get_in(row, path) || 0))
    end)
  end

  defp sum_counts(items, path) do
    items
    |> Enum.reduce(0, fn row, acc ->
      acc + (get_in(row, path) || 0)
    end)
  end

  # defp add_maps(m1, nil), do: m1

  # defp add_maps(m1, m2) do
  #   Map.merge(m1, m2, fn _k, v1, v2 -> v1 + v2 end)
  # end

  def get_unique_users(date) do
    tomorrow = Timex.shift(date, days: 1) |> Timex.to_datetime()
    date = date |> Timex.to_datetime()
    event_type_id = Telemetry.get_or_add_event_type_id("connected", "simple_clientapp")

    # We add 1000 because otherwise it comes back as a charlist and borks a bunch of stuff
    query = """
      SELECT count(DISTINCT user_id) + 1000
      FROM telemetry_simple_clientapp_events
      WHERE event_type_id = $1
        AND inserted_at >= $2
        AND inserted_at < $3
    """

    case Ecto.Adapters.SQL.query(Repo, query, [event_type_id, date, tomorrow]) do
      {:ok, %{rows: [[result]]}} ->
        result - 1000

      {a, b} ->
        raise "ERR: #{a}, #{b}"
    end
  end
end
