defmodule Angen.Logging.PersistGameQuarterTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.Logging
  alias Angen.Logging.GameDayLogLib

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(_) do
    log = do_perform()

    if log != nil do
      %{}
      |> Angen.Logging.PersistGameQuarterTask.new()
      |> Oban.insert()
    end

    :ok
  end

  @spec do_perform() :: {:ok, Logging.GameQuarterLog.t()}
  def do_perform() do
    case Logging.get_last_server_quarter_log_date() do
      nil ->
        perform_first_time()

      date ->
        perform_standard(date)
    end
  end

  # For when there are no existing logs
  # we need to ensure the earliest log is from last quarter, not this quarter
  defp perform_first_time() do
    first_logs =
      Logging.list_server_day_logs(
        order: "Oldest first",
        limit: 1
      )

    case first_logs do
      [log] ->
        today_quarter = Timex.today() |> Timex.quarter()
        log_quarter = log.date |> Timex.quarter()

        if log.date.year < Timex.today().year or log_quarter < today_quarter do
          start_date = Timex.beginning_of_quarter(log.date)
          end_date = Timex.end_of_quarter(log.date) |> Timex.shift(days: 1)

          generate_log(start_date, end_date)
        end

      _ ->
        nil
    end
  end

  # For when we have an existing log
  defp perform_standard(log_date) do
    new_date = Timex.shift(log_date, months: 3)

    new_quarter = new_date |> Timex.quarter()
    today_quarter = Timex.today() |> Timex.quarter()

    if new_date.year < Timex.today().year or new_quarter < today_quarter do
      start_date = Timex.beginning_of_quarter(new_date)
      end_date = Timex.end_of_quarter(new_date) |> Timex.shift(days: 1)

      generate_log(start_date, end_date)
    else
      nil
    end
  end

  defp generate_log(start_date, end_date) do
    stats = GameDayLogLib.calculate_period_statistics(start_date, end_date)

    data =
      Logging.list_server_day_logs(
        search: [
          after: start_date,
          before: end_date
        ]
      )
      |> GameDayLogLib.aggregate_day_logs()
      |> Map.put(:stats, stats)

    quarter = Timex.quarter(start_date)

    {:ok, _} =
      Logging.create_server_quarter_log(%{
        year: start_date.year,
        quarter: quarter,
        date: Timex.beginning_of_quarter(start_date),
        data: data
      })
  end

  @spec quarter_so_far() :: map()
  def quarter_so_far() do
    start_date = Timex.beginning_of_quarter(Timex.now())
    end_date = Timex.shift(start_date, days: 7)

    stats =
      GameDayLogLib.calculate_period_statistics(start_date, Timex.shift(end_date, days: 1))

    Logging.list_server_day_logs(
      where: [
        after: start_date
      ]
    )
    |> Logging.GameDayLogLib.aggregate_day_logs()
    |> Map.put(:stats, stats)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end
end
