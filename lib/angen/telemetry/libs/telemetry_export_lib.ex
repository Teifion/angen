defmodule Angen.Telemetry.TelemetryExportLib do
  @moduledoc false

  alias Angen.Telemetry
  import Angen.Helper.TimexHelper, only: [date_to_str: 1]
  import Ecto.Query, warn: false

  @spec new_export(map()) :: Ecto.UUID.t()
  def new_export(params) do
    id = Teiserver.uuid()

    File.mkdir("/tmp/#{id}")

    [
      export_simple_anon(id, params),
      export_complex_anon(id, params),
      export_simple_clientapp(id, params),
      export_complex_clientapp(id, params),
      export_simple_server(id, params),
      export_complex_server(id, params),
      export_simple_lobby(id, params),
      export_complex_lobby(id, params),
      export_simple_match(id, params),
      export_complex_match(id, params)
    ]

    System.shell("cd /tmp/#{id}; tar -czf /tmp/#{id}.tar.gz *.csv")

    File.rm_rf("/tmp/#{id}")

    id
  end

  defp export_simple_anon(id, params) do
    csv_data =
      Telemetry.list_simple_anon_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.hash_id,
          e.event_type.name,
          date_to_str(e.inserted_at)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(hash_id type inserted_at)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/simple_anon.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_complex_anon(id, params) do
    csv_data =
      Telemetry.list_complex_anon_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.hash_id,
          e.event_type.name,
          date_to_str(e.inserted_at),
          Jason.encode!(e.details)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(hash_id type inserted_at details)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/complex_anon.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_simple_clientapp(id, params) do
    csv_data =
      Telemetry.list_simple_clientapp_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.user_id,
          e.event_type.name,
          date_to_str(e.inserted_at)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(user_id type inserted_at)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/simple_clientapp.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_complex_clientapp(id, params) do
    csv_data =
      Telemetry.list_complex_clientapp_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.user_id,
          e.event_type.name,
          date_to_str(e.inserted_at),
          Jason.encode!(e.details)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(user_id type inserted_at details)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/complex_clientapp.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_simple_server(id, params) do
    csv_data =
      Telemetry.list_simple_server_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.user_id,
          e.event_type.name,
          date_to_str(e.inserted_at)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(user_id type inserted_at)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/simple_server.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_complex_server(id, params) do
    csv_data =
      Telemetry.list_complex_server_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.user_id,
          e.event_type.name,
          date_to_str(e.inserted_at),
          Jason.encode!(e.details)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(user_id type inserted_at details)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/complex_server.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_simple_lobby(id, params) do
    csv_data =
      Telemetry.list_simple_lobby_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.user_id,
          e.match_id,
          e.event_type.name,
          date_to_str(e.inserted_at)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(user_id match_id type inserted_at)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/simple_lobby.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_complex_lobby(id, params) do
    csv_data =
      Telemetry.list_complex_lobby_events(
        where: [
          after: params["start_date"],
          before: params["end_date"]
        ],
        preload: [:event_type],
        order_by: ["Oldest first"],
        limit: :infinity
      )
      |> Stream.map(fn e ->
        [
          e.user_id,
          e.match_id,
          e.event_type.name,
          date_to_str(e.inserted_at),
          Jason.encode!(e.details)
        ]
      end)
      |> Enum.to_list()
      |> List.insert_at(
        0,
        ~w(user_id match_id type inserted_at details)
      )
      |> CSV.encode()
      |> Enum.to_list()

    path = "/tmp/#{id}/complex_lobby.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_simple_match(id, params) do
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

    path = "/tmp/#{id}/simple_match.csv"
    :ok = File.write(path, csv_data)
  end

  defp export_complex_match(id, params) do
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

    path = "/tmp/#{id}/complex_match.csv"
    :ok = File.write(path, csv_data)
  end
end
