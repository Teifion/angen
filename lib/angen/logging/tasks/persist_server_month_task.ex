defmodule Angen.Logging.PersistServerMonthTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.Logging
  alias Angen.Logging.ServerDayLogLib

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(_) do
    log = do_perform()

    if log != nil do
      %{}
      |> Angen.Logging.PersistServerMonthTask.new()
      |> Oban.insert()
    end

    :ok
  end

  @spec do_perform() :: {:ok, Logging.ServerMonthLog.t()}
  def do_perform() do
    case Logging.get_last_server_month_log_date() do
      nil ->
        perform_first_time()

      date ->
        {y, m} = next_month({date.year, date.month})
        perform_standard(y, m)
    end
  end

  # For when there are no existing logs
  # we need to ensure the earliest log is from last month, not this month
  defp perform_first_time() do
    first_logs =
      Logging.list_server_day_logs(
        order_by: "Oldest first",
        limit: 1
      )

    case first_logs do
      [log] ->
        today = Timex.today()

        if log.date.year < today.year or log.date.month < today.month do
          start_date = Timex.beginning_of_month(log.date)
          end_date = Timex.end_of_month(log.date) |> Timex.shift(days: 1)

          generate_log(start_date, end_date)
        end

      _ ->
        nil
    end
  end

  # For when we have an existing log
  defp perform_standard(year, month) do
    today = Timex.today()

    if year < today.year or month < today.month do
      start_date = Timex.Date.new!(year, month, 1)
      end_date = Timex.end_of_month(start_date) |> Timex.shift(days: 1)

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

    {:ok, _} =
      Logging.create_server_month_log(%{
        year: start_date.year,
        month: start_date.month,
        date: Timex.beginning_of_month(start_date),
        data: data
      })
  end

  @spec month_so_far() :: map()
  def month_so_far() do
    start_date = Timex.beginning_of_month(Timex.now())
    end_date = Timex.shift(start_date, days: 7)

    stats =
      ServerDayLogLib.calculate_period_statistics(start_date, Timex.shift(end_date, days: 1))

    Logging.list_server_day_logs(
      where: [
        after: Timex.to_date(start_date)
      ]
    )
    |> Logging.ServerDayLogLib.aggregate_day_logs()
    |> Map.put(:stats, stats)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end

  defp next_month({year, 12}), do: {year + 1, 1}
  defp next_month({year, month}), do: {year, month + 1}
end
