defmodule AngenWeb.Admin.Logging.Server.ShowLive do
  @moduledoc false
  use AngenWeb, :live_view
  alias Angen.Helper.TimexHelper
  alias Angen.Logging

  @impl true
  def mount(params, _session, socket) when is_connected?(socket) do
    date = case params["data"] do
      "today" ->
        Timex.today()
      date_str ->
        TimexHelper.parse_ymd(date_str)
    end

    socket = socket
      |> assign(:unit, params["unit"])
      |> assign(:date_str, params["date"])
      |> assign(:date, date)
      |> assign(:mode, Map.get(params, "mode", "overview"))
      |> assign(:site_menu_active, "logging")
      |> get_log()

    {:ok, socket}
  end

  def mount(params, _session, socket) do
    {:ok, socket
      |> assign(:unit, params["unit"])
      |> assign(:date_str, params["date"])
      |> assign(:mode, Map.get(params, "mode", "overview"))
      |> assign(:site_menu_active, "logging")
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-mode:" <> mode, _event_data, socket) do
    socket = socket
      |> assign(:mode, mode)

    {:noreply, socket}
  end

  def handle_event(_event_text, _event_data, %{assigns: _assigns} = socket) do
    {:noreply, socket}
  end

  defp get_log(%{assigns: %{date_str: "today"}} = socket) do
    {data, events} = Angen.Logging.PersistServerDayTask.today_so_far()
      |> process_data

    socket
      |> assign(:data, data)
      |> assign(:events, events)
  end

  defp get_log(%{assigns: %{date: nil}} = socket) do
    socket
      |> assign(:data, nil)
  end

  defp get_log(%{assigns: %{unit: unit, date: date}} = socket) do
    raw_data = case unit do
      "day" ->
        Logging.get_server_day_log(date) |> Map.get(:data)

    end

    {data, events} = process_data(raw_data)

    socket
      |> assign(:data, data)
      |> assign(:events, events)
  end

  @spec process_data(map()) :: {map(), map()}
  defp process_data(raw_data) do
    events = raw_data["telemetry"]
      |> Map.new(fn {type, counts} ->
        sorted_counts = counts
          |> Enum.map(fn {k, v} -> {k, v} end)
          |> Enum.sort_by(fn {_, v} -> v end, &<=/2)

        {type, sorted_counts}
      end)

    {
      Map.drop(raw_data, ["telemetry"]),
      events
    }
  end
end
