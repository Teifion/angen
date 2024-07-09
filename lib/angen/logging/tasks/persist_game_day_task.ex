defmodule Angen.Logging.PersistGameDayTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.{Repo, Logging}
  alias Angen.Logging.GameDayLogLib
  alias Teiserver.Game

  import Angen.Logging.PersistServerMinuteTask, only: [add_total_key: 1]

  @match_table Teiserver.Game.Match.__schema__(:source)
  @match_setting_table Teiserver.Game.MatchSetting.__schema__(:source)

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
        |> Angen.Logging.PersistGameDayTask.new()
        |> Oban.insert()
      end
    end

    :ok
  end

  @spec do_perform(Date.t(), boolean()) :: :ok
  def do_perform(date, cleanup) do
    start_date = Timex.to_date(date)
    end_date = Timex.shift(start_date, days: 1)

    data = generate_game_summary_data(start_date, end_date)

    # Delete old log if it exists
    Logging.server_day_log_query(
      where: [date: start_date],
      limit: :infinity
    )
    |> Repo.delete_all()

    Logging.create_server_day_log(%{
      date: start_date,
      data: data
    })

    :ok
  end

  def today_so_far() do
    start_date = Timex.today()
    end_date = Timex.shift(start_date, days: 1)

    generate_game_summary_data(start_date, end_date)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end

  @spec generate_game_summary_data(Date.t, Date.t) :: map
  def generate_game_summary_data(start_date, end_date) do
    start_date = Timex.to_datetime(start_date)
    end_date = Timex.to_datetime(end_date)

    %{
      matches: %{
        raw_counts: %{
          type: match_count_by_grouping(start_date, end_date, "type_id") |> match_type_keyswap,
          rated: match_count_by_grouping(start_date, end_date, "rated?"),
          team_size: match_count_by_grouping(start_date, end_date, "team_size"),
          team_count: match_count_by_grouping(start_date, end_date, "team_count")
        },
        player_counts: %{
          type: player_count_by_grouping(start_date, end_date, "type_id") |> match_type_keyswap,
          rated: player_count_by_grouping(start_date, end_date, "rated?"),
          team_size: player_count_by_grouping(start_date, end_date, "team_size"),
          team_count: player_count_by_grouping(start_date, end_date, "team_count")
        },
        player_hours: %{
          type: player_hours_by_grouping(start_date, end_date, "type_id") |> match_type_keyswap,
          rated: player_hours_by_grouping(start_date, end_date, "rated?"),
          team_size: player_hours_by_grouping(start_date, end_date, "team_size"),
          team_count: player_hours_by_grouping(start_date, end_date, "team_count")
        },
      },

      settings: %{
        map: %{
          raw_count: match_count_by_setting_value(start_date, end_date, "map"),
          player_counts: player_count_by_setting_value(start_date, end_date, "map"),
          player_hours: player_hours_by_setting_value(start_date, end_date, "map"),
        }
      }
    }
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
    |> add_total_key
  end

  defp player_count_by_grouping(start_date, end_date, group_by) do
    query = """
      SELECT m."#{group_by}", SUM(m.team_count * m.team_size)
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
    |> add_total_key
  end

  defp player_hours_by_grouping(start_date, end_date, group_by) do
    query = """
      SELECT m."#{group_by}", SUM(m.team_count * m.team_size * m.match_duration_seconds)/3600
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
    |> add_total_key
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
    |> add_total_key
  end

  defp player_count_by_setting_value(start_date, end_date, setting_key) do
    setting_type_id = Game.get_or_create_match_setting_type_id(setting_key)

    query = """
      SELECT ms.value, SUM(m.team_count * m.team_size)
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
    |> add_total_key
  end

  defp player_hours_by_setting_value(start_date, end_date, setting_key) do
    setting_type_id = Game.get_or_create_match_setting_type_id(setting_key)

    query = """
      SELECT ms.value, SUM(m.team_count * m.team_size * m.match_duration_seconds)/3600
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
    |> add_total_key
  end

  defp match_type_keyswap(m) do
    m
    |> Map.new(fn
      {:total, v} -> {"total", v}
      {key_id, v} -> {Game.get_or_create_match_type(key_id).name, v}
    end)
  end
end
