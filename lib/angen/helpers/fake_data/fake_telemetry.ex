defmodule Angen.FakeData.FakeTelemetry do
  @moduledoc false

  alias Angen.Telemetry
  import Mix.Tasks.Angen.Fakedata, only: [valid_userids: 1]

  def make_events(config) do
    Range.new(0, config.days)
    |> Enum.each(fn day ->
      date = Timex.today() |> Timex.shift(days: -day)

      make_simple_client(config, date)
      make_simple_lobby(config, date)
    end)
  end

  def make_simple_client(_config, date) do
    user_ids = valid_userids(date)

    %{
      "connected" => insert_simple_client("connected", user_ids, [0, 1, 2, 3], date),
      "disconnected" => insert_simple_client("disconnected", user_ids, [0, 1, 2, 3], date)
    }
  end

  def make_simple_lobby(_config, _date) do
    %{
      # "cycle" => insert_simple_lobby("cycle", user_ids, [0, 1, 2, 3], date)
    }
  end

  defp insert_simple_client(event_name, user_ids, event_count, date) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_clientapp")

    events =
      user_ids
      |> Enum.map(fn user_id ->
        actual_count = evaluate_count(event_count)

        if actual_count > 0 do
          Range.new(0, actual_count)
          |> Enum.map(fn _ ->
            %{
              event_type_id: type_id,
              user_id: user_id,
              inserted_at: random_time_in_day(date)
            }
          end)
        else
          []
        end
      end)
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleClientappEvent, events)
    |> Angen.Repo.transaction()
  end

  # Allows us to have counts of various types
  defp evaluate_count(c) when is_list(c), do: Enum.random(c)
  defp evaluate_count(c) when is_function(c), do: c.()
  defp evaluate_count(c), do: c

  defp random_time_in_day(date) do
    date
    |> Timex.to_datetime()
    |> Timex.set(
      hour: :rand.uniform(24) - 1,
      minute: :rand.uniform(60) - 1,
      second: :rand.uniform(60) - 1,
      microsecond: 0
    )
  end
end
