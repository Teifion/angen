defmodule Angen.Logging.PersistGameYearTask do
  @moduledoc false
  use Oban.Worker, queue: :logging
  alias Angen.Logging
  import Angen.Logging.PersistGameDayTask, only: [generate_game_summary_data: 2]

  @impl Oban.Worker
  @spec perform(any) :: :ok
  def perform(_) do
    log = do_perform()

    if log != nil do
      %{}
      |> Angen.Logging.PersistGameYearTask.new()
      |> Oban.insert()
    end

    :ok
  end

  @spec do_perform() :: {:ok, Logging.GameYearLog.t()}
  def do_perform() do
    case Logging.get_last_game_year_log_date() do
      nil ->
        perform_first_time()

      date ->
        perform_standard(date)
    end
  end

  # For when there are no existing logs
  # we need to ensure the earliest log is from last year, not this year
  defp perform_first_time() do
    first_logs =
      Logging.list_game_day_logs(
        order_by: "Oldest first",
        limit: 1
      )

    case first_logs do
      [log] ->
        today = Timex.today()

        if log.date.year < today.year do
          start_date = Timex.beginning_of_year(log.date)
          end_date = Timex.end_of_year(log.date)

          generate_log(start_date, end_date)
        end

      _ ->
        nil
    end
  end

  # For when we have an existing log
  defp perform_standard(log_date) do
    new_date = Timex.shift(log_date, years: 1)

    today_year = Timex.today().year

    if new_date.year < today_year do
      start_date = Timex.beginning_of_year(new_date)
      end_date = Timex.end_of_year(new_date) |> Timex.shift(days: 1)

      generate_log(start_date, end_date)
    else
      nil
    end
  end

  defp generate_log(start_date, end_date) do
    data = generate_game_summary_data(start_date, end_date)

    {:ok, _} =
      Logging.create_game_year_log(%{
        year: start_date.year,
        date: Timex.beginning_of_year(start_date),
        data: data
      })
  end

  @spec year_so_far() :: map()
  def year_so_far() do
    start_date = Timex.beginning_of_year(Timex.now())
    end_date = Timex.shift(start_date, days: 7)

    generate_game_summary_data(start_date, end_date)
    |> Jason.encode!()
    |> Jason.decode!()

    # We encode and decode so it's the same format as in the database
  end
end
