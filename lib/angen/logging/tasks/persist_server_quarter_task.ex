defmodule Angen.Logging.PersistServerQuarterTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.Logging
  alias Angen.Logging.ServerDayLogLib
  alias Angen.Helper.DateTimeHelper

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(_) do
    log = do_perform()

    if log != nil do
      %{}
      |> Angen.Logging.PersistServerQuarterTask.new()
      |> Oban.insert()
    end

    :ok
  end

  @spec do_perform() :: {:ok, Logging.ServerQuarterLog.t()}
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
        order_by: "Oldest first",
        limit: 1
      )

    case first_logs do
      [log] ->
        today_quarter = DateTimeHelper.today() |> Date.quarter_of_year()
        log_quarter = log.date |> Date.quarter_of_year()

        if log.date.year < DateTimeHelper.today().year or log_quarter < today_quarter do
          start_date = DateTimeHelper.beginning_of_quarter(log.date)
          end_date = Date.shift(start_date, month: 3)

          generate_log(start_date, end_date)
        end

      _ ->
        nil
    end
  end

  # For when we have an existing log
  defp perform_standard(log_date) do
    new_date = Date.shift(log_date, month: 3)

    new_quarter = new_date |> Date.quarter_of_year()
    today_quarter = DateTimeHelper.today() |> Date.quarter_of_year()

    if new_date.year < DateTimeHelper.today().year or new_quarter < today_quarter do
      start_date = DateTimeHelper.beginning_of_quarter(new_date)
      end_date = Date.shift(start_date, month: 3)

      generate_log(start_date, end_date)
    else
      nil
    end
  end

  defp generate_log(start_date, end_date) do
    stats = ServerDayLogLib.calculate_period_statistics(start_date, end_date)

    data =
      Logging.list_server_day_logs(
        search: [
          after: start_date,
          before: end_date
        ]
      )
      |> ServerDayLogLib.aggregate_day_logs()
      |> Map.put(:stats, stats)

    quarter = Date.quarter_of_year(start_date)

    {:ok, _} =
      Logging.create_server_quarter_log(%{
        year: start_date.year,
        quarter: quarter,
        date: DateTimeHelper.beginning_of_quarter(start_date),
        data: data
      })
  end

  @spec quarter_so_far() :: map()
  def quarter_so_far() do
    start_date = Date.quarter_of_year(DateTime.utc_now())
    end_date = DateTime.shift(start_date, day: 7)

    stats =
      ServerDayLogLib.calculate_period_statistics(start_date, DateTime.shift(end_date, day: 1))

    Logging.list_server_day_logs(
      where: [
        after: start_date
      ]
    )
    |> Logging.ServerDayLogLib.aggregate_day_logs()
    |> Map.put(:stats, stats)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end
end
