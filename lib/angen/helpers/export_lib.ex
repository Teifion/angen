defmodule Angen.ExportLib do
  @moduledoc false
  # TODO: Some duplication, should probably be refactored

  import Angen.Helper.DateTimeHelper, only: [date_to_str: 1]
  import Ecto.Query, warn: false

  @spec new_export(atom, map()) :: Ecto.UUID.t()
  def new_export(:events, params) do
    Angen.Telemetry.TelemetryExportLib.new_export(params)
  end

  def new_export(:matches, params) do
    id = Teiserver.uuid()

    File.mkdir("/tmp/#{id}")

    [
      export_matches(id, params),
      export_members(id, params),
      export_settings(id, params),
      export_choices(id, params),
      export_simple_events(id, params),
      export_complex_events(id, params)
    ]

    System.shell("cd /tmp/#{id}; tar -czf /tmp/#{id}.tar.gz *.csv")

    File.rm_rf("/tmp/#{id}")

    id
  end

  defp export_matches(id, params) do
    csv_data =
      Teiserver.Game.list_matches(
        where: [
          started_after: params["start_date"],
          started_before: params["end_date"]
        ],
        preload: [:type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn m ->
        [
          m.id,
          m.name,
          Enum.join(m.tags, ","),
          m.public?,
          m.rated?,
          m.game_name,
          m.game_version,
          m.team_count,
          m.team_size,
          m.winning_team,
          m.processed?,
          date_to_str(m.lobby_opened_at),
          date_to_str(m.match_started_at),
          date_to_str(m.match_ended_at),
          m.ended_normally?,
          m.match_duration_seconds,
          m.player_count,
          m.host_id,
          m.lobby_id,
          m.type.name
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(id name tags public? rated? game_name game_version team_count team_size winning_team processed? lobby_opened_at match_started_at match_ended_at ended_normally? match_duration_seconds player_count host_id lobby_id type)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/matches.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_members(id, params) do
    keys = ~w(user_id match_id team_number win? party_id left_after_seconds)a

    match_query =
      Teiserver.Game.MatchQueries.match_query(
        where: [
          started_after: params["start_date"],
          started_before: params["end_date"]
        ],
        limit: :infinity,
        select: [:id]
      )

    mm_query =
      from mm in Teiserver.Game.MatchMembership,
        where: mm.match_id in subquery(match_query)

    csv_data =
      Angen.Repo.all(mm_query)
      |> Stream.map(fn mm ->
        keys
        |> Enum.map(fn k ->
          Map.get(mm, k)
        end)
      end)
      |> Enum.to_list()
      |> List.insert_at(0, keys)
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/members.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_settings(id, params) do
    match_query =
      Teiserver.Game.MatchQueries.match_query(
        where: [
          started_after: params["start_date"],
          started_before: params["end_date"]
        ],
        limit: :infinity,
        select: [:id]
      )

    ms_query =
      from ms in Teiserver.Game.MatchSetting,
        where: ms.match_id in subquery(match_query),
        preload: [:type]

    csv_data =
      Angen.Repo.all(ms_query)
      |> Stream.map(fn ms ->
        [
          ms.type.name,
          ms.match_id,
          ms.value
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(0, ~w(type match_id value))
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/settings.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_choices(id, params) do
    match_query =
      Teiserver.Game.MatchQueries.match_query(
        where: [
          started_after: params["start_date"],
          started_before: params["end_date"]
        ],
        limit: :infinity,
        select: [:id]
      )

    uc_query =
      from uc in Teiserver.Game.UserChoice,
        where: uc.match_id in subquery(match_query),
        preload: [:type]

    csv_data =
      Angen.Repo.all(uc_query)
      |> Stream.map(fn uc ->
        [
          uc.type.name,
          uc.match_id,
          uc.user_id,
          uc.value
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(0, ~w(type match_id user_id value))
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/choices.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_simple_events(id, params) do
    match_query =
      Teiserver.Game.MatchQueries.match_query(
        where: [
          started_after: params["start_date"],
          started_before: params["end_date"]
        ],
        limit: :infinity,
        select: [:id]
      )

    events_query =
      from events in Angen.Telemetry.SimpleMatchEvent,
        where: events.match_id in subquery(match_query),
        preload: [:event_type]

    csv_data =
      Angen.Repo.all(events_query)
      |> Stream.map(fn event ->
        [
          event.event_type.name,
          event.match_id,
          event.user_id,
          event.game_time_seconds
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(0, ~w(type match_id user_id game_time_seconds))
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/simple_events.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_complex_events(id, params) do
    match_query =
      Teiserver.Game.MatchQueries.match_query(
        where: [
          started_after: params["start_date"],
          started_before: params["end_date"]
        ],
        limit: :infinity,
        select: [:id]
      )

    events_query =
      from events in Angen.Telemetry.ComplexMatchEvent,
        where: events.match_id in subquery(match_query),
        preload: [:event_type]

    csv_data =
      Angen.Repo.all(events_query)
      |> Stream.map(fn event ->
        [
          event.event_type.name,
          event.match_id,
          event.user_id,
          event.game_time_seconds,
          Jason.encode!(event.details)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(0, ~w(type match_id user_id game_time_seconds details))
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/complex_events.csv"
    :ok = File.write(path, csv_data)
  end
end
