defmodule Angen.Logging.PersistGameWeekTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.Logging
  import Angen.Logging.PersistGameDayTask, only: [generate_game_summary_data: 2]
  alias Angen.Helper.DateTimeHelper

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(_) do
    log = do_perform()

    if log != nil do
      %{}
      |> Angen.Logging.PersistGameWeekTask.new()
      |> Oban.insert()
    end

    :ok
  end

  @spec do_perform() :: {:ok, Logging.GameWeekLog.t()}
  def do_perform() do
    case Logging.get_last_game_week_log_date() do
      nil ->
        perform_first_time()

      date ->
        perform_standard(date)
    end
  end

  # For when there are no existing logs
  # we need to ensure the earliest log is from last week, not this week
  defp perform_first_time() do
    first_logs =
      Logging.list_game_day_logs(
        order_by: "Oldest first",
        limit: 1
      )

    case first_logs do
      [log] ->
        {today_year, today_week} = DateTimeHelper.today() |> DateTimeHelper.iso_week()
        {log_year, log_week} = log.date |> DateTimeHelper.iso_week()

        if log_year < today_year or log_week < today_week do
          start_date = Date.beginning_of_week(log.date)
          end_date = DateTime.shift(start_date, week: 1)

          generate_log(start_date, end_date)
        end

      _ ->
        nil
    end
  end

  # For when we have an existing log
  defp perform_standard(log_date) do
    new_date = DateTime.shift(log_date, day: 7)

    {new_year, new_week} = new_date |> DateTimeHelper.iso_week()
    {today_year, today_week} = DateTimeHelper.today() |> DateTimeHelper.iso_week()

    if new_year < today_year or new_week < today_week do
      start_date = Date.beginning_of_week(new_date)
      end_date = DateTime.shift(start_date, week: 1)

      generate_log(start_date, end_date)
    else
      nil
    end
  end

  defp generate_log(start_date, end_date) do
    data = generate_game_summary_data(start_date, end_date)

    {year, week} = DateTimeHelper.iso_week(start_date)

    {:ok, _} =
      Logging.create_game_week_log(%{
        year: year,
        week: week,
        date: Date.beginning_of_week(start_date),
        data: data
      })
  end

  @spec week_so_far() :: map()
  def week_so_far() do
    start_date = Date.beginning_of_week(DateTime.utc_now())
    end_date = DateTime.shift(start_date, day: 7)

    generate_game_summary_data(start_date, end_date)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end
end
