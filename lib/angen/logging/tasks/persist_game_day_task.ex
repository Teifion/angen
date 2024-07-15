defmodule Angen.Logging.PersistGameDayTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.{Repo, Logging}
  alias Teiserver.Game

  @match_table Teiserver.Game.Match.__schema__(:source)
  @match_setting_table Teiserver.Game.MatchSetting.__schema__(:source)

  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(_) do
    last_date = Logging.get_last_game_day_log_date()

    date =
      if last_date == nil do
        get_timestamp_of_first_game()
      else
        last_date
        |> Timex.shift(days: 1)
      end

    if Timex.compare(date, Timex.today()) == -1 do
      do_perform(date)

      new_date = Timex.shift(date, days: 1)

      if Timex.compare(new_date, Timex.today()) == -1 do
        %{}
        |> Angen.Logging.PersistGameDayTask.new()
        |> Oban.insert()
      end
    end

    :ok
  end

  # This is not a query we want to run often but it should only run when we
  # have no game_logs in the DB and thus a very small population of matches
  defp get_timestamp_of_first_game() do
    result =
      Game.get_match(nil,
        where: [ended_normally?: true],
        limit: 1,
        order_by: ["Oldest first"],
        select: [:match_started_at]
      )

    case result do
      nil ->
        # We return a date in the future so it doesn't run
        Timex.today() |> Timex.shift(days: 2)

      %{match_started_at: timestamp} ->
        timestamp |> Timex.to_date()
    end
  end

  @spec do_perform(Date.t()) :: :ok
  def do_perform(date) do
    start_date = Timex.to_date(date)
    end_date = Timex.shift(start_date, days: 1)

    data = generate_game_summary_data(start_date, end_date)

    # Delete old log if it exists
    Logging.game_day_log_query(
      where: [date: start_date],
      limit: :infinity
    )
    |> Repo.delete_all()

    Logging.create_game_day_log(%{
      date: start_date,
      data: data
    })

    :ok
  end

  @spec today_so_far() :: map()
  def today_so_far() do
    start_date = Timex.today()
    end_date = Timex.shift(start_date, days: 1)

    generate_game_summary_data(start_date, end_date)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end

  @spec generate_game_summary_data(Date.t(), Date.t()) :: map
  def generate_game_summary_data(start_date, end_date) do
    start_date = Timex.to_datetime(start_date)
    end_date = Timex.to_datetime(end_date)

    %{
      totals: %{
        raw_count: get_total_match_count(start_date, end_date),
        player_count: get_total_player_count(start_date, end_date),
        player_hours: get_total_player_hours(start_date, end_date)
      },
      matches: %{
        raw_counts: %{
          type: match_count_by_grouping(start_date, end_date, "type_id") |> match_type_key_swap,
          rated: match_count_by_grouping(start_date, end_date, "rated?"),
          team_size: match_count_by_grouping(start_date, end_date, "team_size"),
          team_count: match_count_by_grouping(start_date, end_date, "team_count")
        },
        player_counts: %{
          type: player_count_by_grouping(start_date, end_date, "type_id") |> match_type_key_swap,
          rated: player_count_by_grouping(start_date, end_date, "rated?"),
          team_size: player_count_by_grouping(start_date, end_date, "team_size"),
          team_count: player_count_by_grouping(start_date, end_date, "team_count")
        },
        player_hours: %{
          type: player_hours_by_grouping(start_date, end_date, "type_id") |> match_type_key_swap,
          rated: player_hours_by_grouping(start_date, end_date, "rated?"),
          team_size: player_hours_by_grouping(start_date, end_date, "team_size"),
          team_count: player_hours_by_grouping(start_date, end_date, "team_count")
        }
      },
      settings: %{
        map: %{
          raw_count: match_count_by_setting_value(start_date, end_date, "map"),
          player_counts: player_count_by_setting_value(start_date, end_date, "map"),
          player_hours: player_hours_by_setting_value(start_date, end_date, "map")
        },
        "win-condition": %{
          raw_count: match_count_by_setting_value(start_date, end_date, "win-condition"),
          player_counts: player_count_by_setting_value(start_date, end_date, "win-condition"),
          player_hours: player_hours_by_setting_value(start_date, end_date, "win-condition")
        },
        "starting-resources": %{
          raw_count: match_count_by_setting_value(start_date, end_date, "starting-resources"),
          player_counts:
            player_count_by_setting_value(start_date, end_date, "starting-resources"),
          player_hours: player_hours_by_setting_value(start_date, end_date, "starting-resources")
        }
      },
      duration_minutes: %{
        raw_count: match_count_by_duration_buckets(start_date, end_date),
        player_counts: player_count_by_duration_buckets(start_date, end_date),
        player_hours: player_hours_by_duration_buckets(start_date, end_date)
      },
      start_times: %{
        raw_count: games_by_start_time(start_date, end_date)
      }
    }
  end

  defp get_total_match_count(start_date, end_date) do
    query = """
      SELECT COUNT(m.id)
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
    """

    {:ok, %{rows: [[results]]}} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])
    results
  end

  defp get_total_player_count(start_date, end_date) do
    query = """
      SELECT SUM(m.player_count)
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
    """

    {:ok, %{rows: [[results]]}} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])
    results
  end

  defp get_total_player_hours(start_date, end_date) do
    query = """
      SELECT SUM(m.player_count * m.match_duration_seconds)/3600
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
    """

    {:ok, %{rows: [[results]]}} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])
    results
  end

  defp match_count_by_grouping(start_date, end_date, group_by) do
    query = """
      SELECT m."#{group_by}", COUNT(m.id)
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY m."#{group_by}"
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp player_count_by_grouping(start_date, end_date, group_by) do
    query = """
      SELECT m."#{group_by}", SUM(m.player_count)
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY m."#{group_by}"
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp player_hours_by_grouping(start_date, end_date, group_by) do
    query = """
      SELECT m."#{group_by}", SUM(m.player_count * m.match_duration_seconds)/3600
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY m."#{group_by}"
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp match_count_by_setting_value(start_date, end_date, setting_key) do
    setting_type_id = Game.get_or_create_match_setting_type_id(setting_key)

    query = """
      SELECT ms.value, COUNT(m.id)
      FROM #{@match_table} m
      JOIN #{@match_setting_table} ms
        ON ms.match_id = m.id
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
        AND ms.type_id = $3
      GROUP BY ms.value
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date, setting_type_id])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp player_count_by_setting_value(start_date, end_date, setting_key) do
    setting_type_id = Game.get_or_create_match_setting_type_id(setting_key)

    query = """
      SELECT ms.value, SUM(m.player_count)
      FROM #{@match_table} m
      JOIN #{@match_setting_table} ms
        ON ms.match_id = m.id
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
        AND ms.type_id = $3
      GROUP BY ms.value
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date, setting_type_id])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp player_hours_by_setting_value(start_date, end_date, setting_key) do
    setting_type_id = Game.get_or_create_match_setting_type_id(setting_key)

    query = """
      SELECT ms.value, SUM(m.player_count * m.match_duration_seconds)/3600
      FROM #{@match_table} m
      JOIN #{@match_setting_table} ms
        ON ms.match_id = m.id
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
        AND ms.type_id = $3
      GROUP BY ms.value
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date, setting_type_id])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp match_count_by_duration_buckets(start_date, end_date) do
    # 12 buckets in 60 minutes, 5 minutes per bucket
    query = """
      SELECT width_bucket(m."match_duration_seconds"/60, 0, 60, 12) * 5 AS bucket, COUNT(m.id)
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY bucket
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp player_count_by_duration_buckets(start_date, end_date) do
    # 12 buckets in 60 minutes, 5 minutes per bucket
    query = """
      SELECT width_bucket(m."match_duration_seconds"/60, 0, 60, 12) * 5 AS bucket, SUM(m.player_count)
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY bucket
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp player_hours_by_duration_buckets(start_date, end_date) do
    # 12 buckets in 60 minutes, 5 minutes per bucket
    query = """
      SELECT width_bucket(m."match_duration_seconds"/60, 0, 60, 12) * 5 AS bucket, SUM(m.player_count * m.match_duration_seconds)/3600
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY bucket
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key, value] -> {key, value} end)
  end

  defp games_by_start_time(start_date, end_date) do
    # 48 buckets in 24 hours minutes, 30 minutes per bucket
    query = """
      SELECT date_part('hour', m."match_started_at") as hour,
        floor(date_part('minute', m."match_started_at")/15) as quarter_hour,
        SUM(m.player_count * m.match_duration_seconds)/3600
      FROM #{@match_table} m
      WHERE m.match_started_at > $1
        AND m.match_started_at < $2
        AND m."processed?" = TRUE
        AND m."ended_normally?" = TRUE
      GROUP BY hour, quarter_hour
    """

    {:ok, results} = Ecto.Adapters.SQL.query(Repo, query, [start_date, end_date])

    results.rows
    |> Map.new(fn [key1, key2, value] -> {"#{round(key1)}.#{round(key2)}", value} end)
  end

  defp match_type_key_swap(m) do
    m
    |> Map.new(fn
      {:total, v} -> {"total", v}
      {key_id, v} -> {Game.get_or_create_match_type(key_id).name, v}
    end)
  end
end
