defmodule AngenWeb.Admin.Logging.Server.NowLive do
  @moduledoc false
  use AngenWeb, :live_view
  alias Angen.Logging
  # alias Angen.Logging.GraphMinuteLogsTask

  @impl true
  def mount(params, _session, socket) when is_connected?(socket) do
    socket = socket
      |> assign(:site_menu_active, "logging")
      |> assign(:resolution, Map.get(params, "resolution", "1") |> String.to_integer())
      |> assign(:minutes, Map.get(params, "minutes", "30") |> String.to_integer())
      |> assign(:mode, "this_minute")
      |> get_logs
      # |> generate_graph_data

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:mode, "this_minute")
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(_event_text, _event_data, %{assigns: _assigns} = socket) do
    {:noreply, socket}
  end

  defp get_logs(%{assigns: %{minutes: _minutes}} = socket) do
    start_timestamp = nil

    logs =
      Logging.list_server_minute_logs(
        order: "Newest first",
        where: [
          # node: "all",
          after: start_timestamp
        ],
        limit: 10
      )
      |> Enum.reverse

    socket
      |> assign(:logs, logs)
  end

  # defp generate_graph_data(%{assigns: %{logs: logs}} = socket) do
  #   socket
  #     |> assign(column_clients: GraphMinuteLogsTask.perform_clients(logs, 1))
  #     # |> assign(columns_matches: GraphMinuteLogsTask.perform_matches(logs, 1))
  #     # |> assign(columns_matches_start_stop: GraphMinuteLogsTask.perform_matches_start_stop(logs, 1))
  #     # |> assign(columns_user_connections: GraphMinuteLogsTask.perform_user_connections(logs, 1))
  #     # |> assign(columns_bot_connections: GraphMinuteLogsTask.perform_bot_connections(logs, 1))
  #     # |> assign(columns_cpu_load: GraphMinuteLogsTask.perform_cpu_load(logs, 1))
  #     |> assign(columns_matches: [])
  #     |> assign(columns_matches_start_stop: [])
  #     |> assign(columns_user_connections: [])
  #     |> assign(columns_bot_connections: [])
  #     |> assign(columns_cpu_load: [])
  #     |> assign(axis_key: GraphMinuteLogsTask.perform_axis_key(logs, 1))
  # end
end
