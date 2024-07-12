defmodule Angen.FakeData.FakeMatches do
  @moduledoc false

  require Logger
  import Angen.Helpers.FakeDataHelper, only: [valid_user_ids: 1, random_time_in_day: 1]
  alias Teiserver.Game
  alias Teiserver.Game.MatchTypeLib

  @bar_format [
    left: [IO.ANSI.green, String.pad_trailing("Matches: ", 20), IO.ANSI.reset, " |"]
  ]

  @tags ~w(tag1 tag2 tag2 tag3 tag3 tag3 tag4 tag4 tag4 tag4)

  defp matches_per_day(user_count), do: :rand.uniform(user_count * 2) + 10

  def make_matches(config) do
    combined_data =
      0..config.days
      |> Enum.map(fn day ->
        ProgressBar.render(day, config.days, @bar_format)
        date = Timex.today() |> Timex.shift(days: -day)

        make_daily_matches(config, date)
      end)
      |> List.flatten()

    {matches, remaining_data} = Enum.unzip(combined_data)
    {memberships, settings} = Enum.unzip(List.flatten(remaining_data))

    ProgressBar.render_spinner [text: "Inserting matches", done: :remove], fn ->
      matches
      |> List.flatten
      |> Enum.chunk_every(1_000)
      |> Enum.each(fn chunk ->
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Game.Match, List.flatten(chunk))
        |> Angen.Repo.transaction()
      end)
    end

    ProgressBar.render_spinner [text: "Inserting memberships", done: :remove], fn ->
      memberships
      |> List.flatten
      |> Enum.chunk_every(8_000)
      |> Enum.each(fn chunk ->
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Game.MatchMembership, List.flatten(chunk))
        |> Angen.Repo.transaction()
      end)
    end

    ProgressBar.render_spinner [text: "Inserting settings", done: :remove], fn ->
      settings
      |> List.flatten
      |> Enum.chunk_every(8_000)
      |> Enum.each(fn m_chunk ->
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Game.MatchSetting, List.flatten(m_chunk))
        |> Angen.Repo.transaction()
      end)
    end
  end

  defp make_daily_matches(config, date) do
    user_ids = valid_user_ids(date)
    match_count = matches_per_day(Enum.count(user_ids))

    0..match_count
    |> Enum.map(fn _ ->
      make_match(date, config, user_ids)
    end)
    |> Enum.unzip()
  end

  defp make_match(date, _config, user_ids) do
    t1 = random_time_in_day(date)
    t2 = Timex.shift(t1, seconds: :rand.uniform(600)) |> Timex.set(microsecond: 0)
    t3 = Timex.shift(t2, seconds: :rand.uniform(3900)) |> Timex.set(microsecond: 0)
    match_duration = Timex.diff(t3, t2, :second)

    team_count = Enum.random([1, 1, 2, 2, 2, 2, 3, 4])
    team_size = Enum.random([1, 1, 1, 1, 2, 3, 4, 5, 8])
    player_count = team_count * team_size

    match =
      %{
        id: Ecto.UUID.generate(),
        name: nil,
        tags: Enum.take_random(@tags, 3) |> Enum.uniq,
        public?: :rand.uniform() < 0.8,
        rated?: :rand.uniform() < 0.8,
        game_name: "MyGame",
        game_version: "v1.#{:rand.uniform(6)}",
        winning_team: nil,
        team_count: team_count,
        team_size: team_size,
        processed?: true,
        ended_normally?: match_duration > 120,
        lobby_opened_at: t1,
        match_started_at: t2,
        match_ended_at: t3,
        match_duration_seconds: match_duration,
        player_count: player_count,
        lobby_id: Ecto.UUID.generate(),
        host_id: Enum.random(user_ids),
        type_id: nil,
        inserted_at: t2,
        updated_at: t3
      }
      |> generate_type()
      |> generate_winning_team()

    {memberships, _} =
      user_ids
      |> Enum.take_random(player_count)
      |> Enum.map_reduce(1, fn user_id, team_number ->
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
        type_id: Game.get_or_create_match_setting_type_id("map"),
        match_id: match.id,
        value: Enum.random(["Honeycomb", "Blueberries", "Chaddington", "Scary Scandals"])
      },
      %{
        type_id: Game.get_or_create_match_setting_type_id("win-condition"),
        match_id: match.id,
        value: Enum.random(["Regicide", "Annihilation", "Score"])
      },
      %{
        type_id: Game.get_or_create_match_setting_type_id("starting-resources"),
        match_id: match.id,
        value: Enum.random(["Broke", "Low", "Normal", "High", "Infinite"])
      }
    ]

    {match, {memberships, settings}}
  end

  defp generate_type(%{team_count: 1, team_size: 1} = data) do
    %{data | name: "Solo", type_id: MatchTypeLib.get_or_create_match_type("Solo").id}
  end

  defp generate_type(%{team_count: 1} = data) do
    %{
      data
      | name: "#{data.team_size} player PvE",
        type_id: MatchTypeLib.get_or_create_match_type("PvE").id
    }
  end

  defp generate_type(%{team_count: 2, team_size: 1} = data) do
    %{data | name: "Duel", type_id: MatchTypeLib.get_or_create_match_type("Duel").id}
  end

  defp generate_type(%{team_count: 2} = data) do
    %{
      data
      | name: "#{data.team_size} v #{data.team_size}",
        type_id: MatchTypeLib.get_or_create_match_type("Team").id
    }
  end

  defp generate_type(%{team_size: 1} = data) do
    %{
      data
      | name: "#{data.team_count} way FFA",
        type_id: MatchTypeLib.get_or_create_match_type("FFA").id
    }
  end

  defp generate_type(data) do
    %{
      data
      | name: "#{data.team_count} way team FFA",
        type_id: MatchTypeLib.get_or_create_match_type("Team FFA").id
    }
  end

  defp generate_winning_team(data) do
    %{data | winning_team: :rand.uniform(data.team_count)}
  end
end
