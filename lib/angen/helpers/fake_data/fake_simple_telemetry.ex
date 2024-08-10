defmodule Angen.FakeData.FakeSimpleTelemetry do
  @moduledoc false

  alias Angen.Telemetry

  import Angen.Helpers.FakeDataHelper,
    only: [valid_user_ids: 1, random_time_in_day: 1, matches_this_day: 1]

  @bar_format [
    left: [IO.ANSI.green(), String.pad_trailing("Simple events: ", 20), IO.ANSI.reset(), " |"]
  ]

  def make_simple_events(config) do
    ProgressBar.render(0, config.days, @bar_format)

    0..min(config.days, 90)
    |> Enum.each(fn day ->
      date = Timex.today() |> Timex.shift(days: -day)

      make_simple_anon(config, date)
      make_simple_client(config, date)
      make_simple_lobby(config, date)
      make_simple_match(config, date)
      make_simple_server(config, date)

      ProgressBar.render(day, config.days, @bar_format)
    end)
  end

  def make_simple_anon(_config, date) do
    user_ids = valid_user_ids(date)

    events =
      [
        create_simple_anon("started campaign", user_ids, [0, 0, 1, 2], date),
        create_simple_anon("started skirmish", user_ids, [0, 1, 2, 3], date),
        create_simple_anon("started multiplayer", user_ids, [0, 0, 0, 1], date)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleAnonEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_simple_anon(event_name, user_ids, event_count, date) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_anon")

    user_ids
    |> Enum.map(fn user_id ->
      actual_count = evaluate_count(event_count)

      if actual_count > 0 do
        0..actual_count
        |> Enum.map(fn _ ->
          %{
            event_type_id: type_id,
            hash_id: UUID.uuid5(nil, user_id),
            inserted_at: random_time_in_day(date)
          }
        end)
      else
        []
      end
    end)
  end

  def make_simple_client(_config, date) do
    user_ids = valid_user_ids(date)

    events =
      [
        create_simple_client("clicked-matchmaking", user_ids, [0, 1, 2, 3], date),
        create_simple_client("found-match", user_ids, [0, 1, 2, 3], date)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleClientappEvent, events)
    |> Angen.Repo.transaction()
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

  def make_simple_lobby(_config, date) do
    match_ids = matches_this_day(date)
    user_ids = valid_user_ids(date)

    events =
      [
        create_simple_lobby("cycle", match_ids, user_ids, [0, 1, 2, 3], date)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleLobbyEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_simple_lobby(event_name, match_ids, user_ids, event_count, date) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_lobby")

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
            inserted_at: random_time_in_day(date)
          }
        end)
      else
        []
      end
    end)
  end

  def make_simple_match(_config, date) do
    match_ids = matches_this_day(date)
    user_ids = valid_user_ids(date)

    events =
      [
        create_simple_match("produced-first-worker", match_ids, user_ids, 1, date),
        create_simple_match("auto-scout", match_ids, user_ids, [0, 0, 1], date),
        create_simple_match("ultimate-ability", match_ids, user_ids, [0, 0, 0, 1, 2, 3], date)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleMatchEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_simple_match(event_name, match_ids, user_ids, event_count, date) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_match")

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
            game_time_seconds: :rand.uniform(600)
          }
        end)
      else
        []
      end
    end)
  end

  def make_simple_server(_config, date) do
    user_ids = valid_user_ids(date)

    events =
      [
        create_simple_server("banned user denied", user_ids, [0, 0, 0, 0, 0, 1], date)
      ]
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleServerEvent, events)
    |> Angen.Repo.transaction()
  end

  defp create_simple_server(event_name, user_ids, event_count, date) do
    type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_server")

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
