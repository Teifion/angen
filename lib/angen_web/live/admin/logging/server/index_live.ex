defmodule AngenWeb.Admin.Logging.Server.IndexLive do
  @moduledoc false
  use AngenWeb, :live_view

  alias Angen.Logging

  @impl true
  def mount(params, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "logging")
      |> assign(:unit, Map.get(params, "unit", "day"))
      |> assign(:limit, 31)
      |> assign(:mode, "table")
      |> get_logs

    {:ok, socket}
  end

  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "logging")
     |> assign(:unit, Map.get(params, "unit", "day"))
     |> assign(:limit, 31)
     |> assign(:mode, "table")
     |> assign(:logs, [])}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-unit:" <> unit, _event_data, socket) do
    socket =
      socket
      |> assign(:unit, unit)
      |> get_logs

    {:noreply, socket}
  end

  def handle_event(_event_text, _event_data, %{assigns: _assigns} = socket) do
    {:noreply, socket}
  end

  @spec get_logs(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_logs(%{assigns: assigns} = socket) do
    unit = assigns.unit
    limit = assigns.limit

    logs =
      case unit do
        "minute" ->
          Logging.list_server_minute_logs(
            where: [node: "all"],
            order_by: "Newest first",
            limit: limit
          )

        "day" ->
          Logging.list_server_day_logs(
            order_by: "Newest first",
            limit: limit
          )

        "week" ->
          Logging.list_server_week_logs(
            order_by: "Newest first",
            limit: limit
          )

        "month" ->
          Logging.list_server_month_logs(
            order_by: "Newest first",
            limit: limit
          )

        "quarter" ->
          Logging.list_server_quarter_logs(
            order_by: "Newest first",
            limit: limit
          )

        "year" ->
          Logging.list_server_year_logs(
            order_by: "Newest first",
            limit: limit
          )

        _ ->
          []
      end

    socket
    |> assign(:logs, logs)
  end
end
