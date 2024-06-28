defmodule Angen.FakeData.FakeMatches do
  @moduledoc false

  import Mix.Tasks.Angen.Fakedata, only: [valid_userids: 1, random_time_in_day: 1]
  alias Angen.Helper.TimexHelper
  alias Teiserver.Game
  alias Teiserver.Game.MatchTypeLib

  defp matches_per_day(), do: :rand.uniform(5) + 2

  def make_matches(config) do
    combined_data = 0..config.days
    |> Enum.map(fn day ->
      date = Timex.today() |> Timex.shift(days: -day)

      make_daily_matches(config, date)
    end)
    |> List.flatten

    {matches, remaining_data} = Enum.unzip(combined_data)
    {memberships, settings} = Enum.unzip(List.flatten(remaining_data))

    matches = List.flatten(matches)
    memberships = List.flatten(memberships)
    settings = List.flatten(settings)

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Game.Match, List.flatten(matches))
    |> Angen.Repo.transaction()

    memberships
    |> Enum.chunk_every(8_000)
    |> Enum.each(fn chunk ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, Game.MatchMembership, List.flatten(chunk))
      |> Angen.Repo.transaction()
    end)

    settings
    |> Enum.chunk_every(8_000)
    |> Enum.each(fn m_chunk ->
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, Game.MatchSetting, List.flatten(m_chunk))
      |> Angen.Repo.transaction()
    end)
  end

  defp make_daily_matches(config, date) do
    user_ids = valid_userids(date)

    0..matches_per_day()
    |> Enum.map(fn _ ->
      make_match(date, config, user_ids)
    end)
    |> Enum.unzip
  end

  defp make_match(date, _config, user_ids) do
    [t1, t2, t3] = 0..2
      |> Enum.map(fn _ -> random_time_in_day(date) end)
      |> Enum.sort_by(fn v -> v end, &TimexHelper.less_than/2)

    match = %{
      id: Ecto.UUID.generate(),
      name: nil,
      tags: [],
      public?: (:rand.uniform() < 0.8),
      rated?: (:rand.uniform() < 0.8),
      game_name: "MyGame",
      game_version: "v1.#{:rand.uniform(6)}",
      winning_team: nil,
      team_count: Enum.random([1, 1, 2, 2, 2, 2, 3, 4]),
      team_size: Enum.random([1, 1, 1, 1, 2, 3, 4, 5, 8]),
      processed?: false,
      ended_normally?: (:rand.uniform() < 0.8),
      lobby_opened_at: t1,
      match_started_at: t2,
      match_ended_at: t3,
      match_duration_seconds: Timex.diff(t3, t2, :second),
      lobby_id: Ecto.UUID.generate(),

      host_id: Enum.random(user_ids),
      type_id: nil,

      inserted_at: t2,
      updated_at: t3
    }
    |> generate_type()
    |> generate_winning_team()

    member_count = match.team_count * match.team_size

    {memberships, _} = user_ids
      |> Enum.take_random(member_count)
      |> Enum.map_reduce(1, fn (user_id, team_number) ->
        new_team_number = team_number + 1
        new_team_number = if new_team_number > match.team_count, do: 1, else: new_team_number

        {%{
          match_id: match.id,
          user_id: user_id,
          team_number: team_number,
          win?: team_number == match.winning_team,
          party_id: nil,
          left_after_seconds: nil
        }, new_team_number}
      end)

    settings = [
      %{
        type_id: Game.get_or_create_match_setting_type("map"),
        match_id: match.id,
        value: Enum.random(["Honeycomb", "Blueberries", "Chaddington", "Scary Scandals"])
      },
      %{
        type_id: Game.get_or_create_match_setting_type("win-condition"),
        match_id: match.id,
        value: Enum.random(["Regicide", "Annihilation", "Score"])
      },
      %{
        type_id: Game.get_or_create_match_setting_type("starting-resources"),
        match_id: match.id,
        value: Enum.random(["Broke", "Low", "Normal", "High", "Infinite"])
      }
    ]

    {match, {memberships, settings}}
  end

  defp generate_type(%{team_count: 1, team_size: 1} = data) do
    %{data |
      name: "Solo",
      type_id: MatchTypeLib.get_or_create_match_type("Solo").id
    }
  end

  defp generate_type(%{team_count: 1} = data) do
    %{data |
      name: "#{data.team_size} player PvE",
      type_id: MatchTypeLib.get_or_create_match_type("PvE").id
    }
  end

  defp generate_type(%{team_count: 2, team_size: 1} = data) do
    %{data |
      name: "Duel",
      type_id: MatchTypeLib.get_or_create_match_type("Duel").id
    }
  end

  defp generate_type(%{team_count: 2} = data) do
    %{data |
      name: "#{data.team_size} v #{data.team_size}",
      type_id: MatchTypeLib.get_or_create_match_type("Team").id
    }
  end

  defp generate_type(%{team_size: 1} = data) do
    %{data |
      name: "#{data.team_count} way FFA",
      type_id: MatchTypeLib.get_or_create_match_type("FFA").id
    }
  end

  defp generate_type(data) do
    %{data |
      name: "#{data.team_count} way team FFA",
      type_id: MatchTypeLib.get_or_create_match_type("Team FFA").id
    }
  end

  defp generate_winning_team(data) do
    %{data | winning_team: :rand.uniform(data.team_count)}
  end

  # def make_simple_client(_config, date) do
  #   user_ids = valid_userids(date)

  #   events = [
  #     create_simple_client("connected", user_ids, [0, 1, 2, 3], date),
  #     create_simple_client("disconnected", user_ids, [0, 1, 2, 3], date)
  #   ]
  #   |> List.flatten()

  #   Ecto.Multi.new()
  #   |> Ecto.Multi.insert_all(:insert_all, Telemetry.SimpleClientappEvent, events)
  #   |> Angen.Repo.transaction()
  # end

  # def make_simple_lobby(_config, _date) do
  #   %{
  #     # "cycle" => insert_simple_lobby("cycle", user_ids, [0, 1, 2, 3], date)
  #   }
  # end

  # defp create_simple_client(event_name, user_ids, event_count, date) do
  #   type_id = Telemetry.get_or_add_event_type_id(event_name, "simple_clientapp")

  #   user_ids
  #   |> Enum.map(fn user_id ->
  #     actual_count = evaluate_count(event_count)

  #     if actual_count > 0 do
  #       0..actual_count
  #       |> Enum.map(fn _ ->
  #         %{
  #           event_type_id: type_id,
  #           user_id: user_id,
  #           inserted_at: random_time_in_day(date)
  #         }
  #       end)
  #     else
  #       []
  #     end
  #   end)
  # end

  # # Allows us to have counts of various types
  # defp evaluate_count(c) when is_list(c), do: Enum.random(c)
  # defp evaluate_count(c) when is_function(c), do: c.()
  # defp evaluate_count(c), do: c
end
