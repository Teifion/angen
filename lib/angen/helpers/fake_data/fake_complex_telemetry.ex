defmodule Angen.FakeData.FakeComplexTelemetry do
  @moduledoc false

  alias Angen.Telemetry
  alias Angen.Helper.DateTimeHelper

  import Angen.Helpers.FakeDataHelper,
    only: [valid_user_ids: 1, random_time_in_day: 1, matches_this_day: 1]

  @bar_format [
    left: [IO.ANSI.green(), String.pad_trailing("Complex events: ", 20), IO.ANSI.reset(), " |"]
  ]

  def make_complex_events(config) do
    0..min(config.days, 90)
    |> Enum.each(fn day ->
      ProgressBar.render(day, config.days, @bar_format)
      date = DateTimeHelper.today() |> Date.shift(day: -day)

      make_complex_anon(config, date)
      make_complex_client(config, date)
      make_complex_lobby(config, date)
      make_complex_match(config, date)
      make_complex_server(config, date)
    end)
  end

  def make_complex_anon(_config, date) do
    user_ids = valid_user_ids(date)

    events =
      [
        create_complex_anon("daily-feedback", user_ids, [0, 0, 0, 1], date, fn ->
          %{"gameplay" => :rand.uniform(5), "community" => :rand.uniform(5)}
        end),
        create_complex_anon("completed-tutorial", user_ids, [0, 0, 0, 1], date, fn ->
          %{"time_taken_seconds" => :rand.uniform(900) + 150}
        end),
        create_complex_anon("system-specs", user_ids, [0, 0, 1], date, fn ->
          %{"VRAM" => Enum.random([1, 2, 4]), "RAM" => Enum.random([4, 8, 16, 32])}
        end)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.ComplexAnonEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_complex_anon(event_name, user_ids, event_count, date, value_function) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "complex_anon")

    user_ids
    |> Enum.map(fn user_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
        |> Enum.map(fn _ ->
          %{
            event_type_id: type_id,
            hash_id: UUID.uuid5(nil, user_id),
            inserted_at: random_time_in_day(date),
            details: value_function.()
          }
        end)
      else
        []
      end
    end)
  end

  def make_complex_client(_config, date) do
    user_ids = valid_user_ids(date)

    events =
      [
        create_complex_client("daily-feedback", user_ids, [0, 0, 0, 1], date, fn ->
          %{"gameplay" => :rand.uniform(5), "community" => :rand.uniform(5)}
        end),
        create_complex_client("completed-tutorial", user_ids, [0, 0, 0, 1], date, fn ->
          %{"time_taken_seconds" => :rand.uniform(900) + 150}
        end)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.ComplexClientappEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_complex_client(event_name, user_ids, event_count, date, value_function) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "complex_clientapp")

    user_ids
    |> Enum.map(fn user_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
        |> Enum.map(fn _ ->
          %{
            event_type_id: type_id,
            user_id: user_id,
            inserted_at: random_time_in_day(date),
            details: value_function.()
          }
        end)
      else
        []
      end
    end)
  end

  def make_complex_lobby(_config, date) do
    match_ids = matches_this_day(date)
    user_ids = valid_user_ids(date)

    events =
      [
        create_complex_lobby("spec command", match_ids, user_ids, [0, 1, 2, 3], date, fn ->
          %{"target" => Enum.random(user_ids)}
        end)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.ComplexLobbyEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_complex_lobby(event_name, match_ids, user_ids, event_count, date, value_function) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "complex_lobby")

    match_ids
    |> Enum.map(fn match_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
        |> Enum.map(fn _ ->
          %{
            event_type_id: type_id,
            user_id: Enum.random(user_ids),
            match_id: match_id,
            inserted_at: random_time_in_day(date),
            details: value_function.()
          }
        end)
      else
        []
      end
    end)
  end

  def make_complex_match(_config, date) do
    match_ids = matches_this_day(date)
    user_ids = valid_user_ids(date)

    events =
      [
        create_complex_match("died", match_ids, user_ids, [0, 0, 1], date, fn ->
          %{"source" => Enum.random(~w(Bug Robot Gravity FriendlyFire))}
        end),
        create_complex_match("first-completion", match_ids, user_ids, 1, date, fn ->
          %{"unit" => Enum.random(~w(tank-factory infantry-factory silo farm))}
        end),
        create_complex_match("initial-tech-choice", match_ids, user_ids, 1, date, fn ->
          %{"unit" => Enum.random(~w(writing astronomy construction wheelbarrow))}
        end)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.ComplexMatchEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_complex_match(event_name, match_ids, user_ids, event_count, date, value_function) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "complex_match")

    match_ids
    |> Enum.map(fn match_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
        |> Enum.map(fn _ ->
          %{
            event_type_id: type_id,
            user_id: Enum.random(user_ids),
            match_id: match_id,
            inserted_at: random_time_in_day(date),
            game_time_seconds: :rand.uniform(600),
            details: value_function.()
          }
        end)
      else
        []
      end
    end)
  end

  def make_complex_server(_config, date) do
    user_ids = valid_user_ids(date)

    events =
      [
        create_complex_server("server-event", user_ids, [0, 0, 0, 0, 0, 1], date, fn ->
          %{"key" => Enum.random(~w(opt1 opt2 opt3))}
        end)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.ComplexServerEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_complex_server(event_name, user_ids, event_count, date, value_function) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "complex_server")

    user_ids
    |> Enum.map(fn user_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
        |> Enum.map(fn _ ->
          %{
            event_type_id: type_id,
            user_id: user_id,
            inserted_at: random_time_in_day(date),
            details: value_function.()
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
