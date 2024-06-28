defmodule Angen.FakeData.FakeTelemetry do
  @moduledoc false

  alias Angen.Telemetry
  import Mix.Tasks.Angen.Fakedata, only: [valid_userids: 1, random_time_in_day: 1]

  def make_events(config) do
    0..min(config.days, 90)
    |> Enum.each(fn day ->
      date = Timex.today() |> Timex.shift(days: -day)

      make_simple_client(config, date)
      make_simple_lobby(config, date)
    end)
  end

  def make_simple_client(_config, date) do
    user_ids = valid_userids(date)

    events = [
      create_simple_client("connected", user_ids, [0, 1, 2, 3], date),
      create_simple_client("disconnected", user_ids, [0, 1, 2, 3], date)
    ]
    |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleClientappEvent, events)
    |> Angen.Repo.transaction()
  end

  def make_simple_lobby(_config, _date) do
    %{
      # "cycle" => insert_simple_lobby("cycle", user_ids, [0, 1, 2, 3], date)
    }
  end

  defp create_simple_client(event_name, user_ids, event_count, date) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_clientapp")

    user_ids
    |> Enum.map(fn user_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
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
  end

  # Allows us to have counts of various types
  defp evaluate_count(c) when is_list(c), do: Enum.random(c)
  defp evaluate_count(c) when is_function(c), do: c.()
  defp evaluate_count(c), do: c
end
