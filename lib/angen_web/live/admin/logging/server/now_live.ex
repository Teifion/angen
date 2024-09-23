defmodule AngenWeb.Admin.Logging.Server.NowLive do
  @moduledoc false
  use AngenWeb, :live_view
  alias Angen.Logging

  @impl true
  def mount(params, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "logging")
      |> assign(:resolution, Map.get(params, "resolution", "1") |> String.to_integer())
      |> assign(:minutes, Map.get(params, "minutes", "30") |> String.to_integer())
      |> assign(:mode, "this_minute")
      |> get_logs

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:mode, "this_minute")}
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
        order_by: "Newest first",
        where: [
          # node: "all",
          after: start_timestamp
        ],
        limit: 10
      )
      |> Enum.reverse()

    socket
    |> assign(:logs, logs)
  end
end
