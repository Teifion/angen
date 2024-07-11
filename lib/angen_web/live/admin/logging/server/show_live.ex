defmodule AngenWeb.Admin.Logging.Server.ShowLive do
  @moduledoc false
  use AngenWeb, :live_view
  alias Angen.Helper.TimexHelper
  alias Angen.Logging

  @impl true
  def mount(params, _session, socket) when is_connected?(socket) do
    date =
      case params["date"] do
        "today" ->
          Timex.today()

        date_str ->
          TimexHelper.parse_ymd(date_str)
      end

    socket =
      socket
      |> assign(:unit, params["unit"])
      |> assign(:date_str, params["date"])
      |> assign(:date, date)
      |> assign(:mode, Map.get(params, "mode", "overview"))
      |> assign(:site_menu_active, "logging")
      |> get_log()

    {:ok, socket}
  end

  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:unit, params["unit"])
     |> assign(:date_str, params["date"])
     |> assign(:mode, Map.get(params, "mode", "overview"))
     |> assign(:site_menu_active, "logging")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-mode:" <> mode, _event_data, socket) do
    socket =
      socket
      |> assign(:mode, mode)

    {:noreply, socket}
  end

  def handle_event(_event_text, _event_data, %{assigns: _assigns} = socket) do
    {:noreply, socket}
  end

  defp get_log(%{assigns: %{date_str: "today", unit: unit}} = socket) do
    {data, events} =
      case unit do
        "week" ->
          Angen.Logging.PersistServerWeekTask.week_so_far()
          |> process_data

        "month" ->
          Angen.Logging.PersistServerMonthTask.month_so_far()
          |> process_data

        "quarter" ->
          Angen.Logging.PersistServerQuarterTask.quarter_so_far()
          |> process_data

        "year" ->
          Angen.Logging.PersistServerYearTask.year_so_far()
          |> process_data

        _day ->
          Angen.Logging.PersistServerDayTask.today_so_far()
          |> process_data
      end

    socket
    |> assign(:data, data)
    |> assign(:events, events)
  end

  defp get_log(%{assigns: %{date: nil}} = socket) do
    socket
    |> assign(:data, nil)
  end

  defp get_log(%{assigns: %{unit: unit, date: date}} = socket) do
    raw_data =
      case unit do
        "week" ->
          Logging.get_server_week_log(date) |> Map.get(:data)

        "month" ->
          Logging.get_server_month_log(date) |> Map.get(:data)

        "quarter" ->
          Logging.get_server_quarter_log(date) |> Map.get(:data)

        "year" ->
          Logging.get_server_year_log(date) |> Map.get(:data)

        _day ->
          Logging.get_server_day_log(date) |> Map.get(:data)
      end

    {data, events} = process_data(raw_data)

    socket
    |> assign(:data, data)
    |> assign(:events, events)
  end

  @spec process_data(map()) :: {map(), map()}
  defp process_data(raw_data) do
    events =
      raw_data["telemetry_events"]
      |> Map.new(fn {type, counts} ->
        sorted_counts =
          counts
          |> Enum.map(fn {k, v} -> {k, v} end)
          |> Enum.sort_by(fn {_, v} -> v end, &>=/2)

        {type, sorted_counts}
      end)
      |> add_empty_events

    {
      raw_data,
      events
    }
  end

  defp add_empty_events(events) do
    Map.merge(
      %{
        "simple_server" => [],
        "simple_clientapp" => [],
        "simple_anon" => [],
        "simple_lobby" => [],
        "simple_match" => [],
        "complex_server" => [],
        "complex_clientapp" => [],
        "complex_anon" => [],
        "complex_lobby" => [],
        "complex_match" => []
      },
      events
    )
  end
end
