defmodule AngenWeb.Admin.Logging.Game.ShowLive do
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
    data =
      case unit do
        "week" ->
          Angen.Logging.PersistGameWeekTask.week_so_far()

        "month" ->
          Angen.Logging.PersistGameMonthTask.month_so_far()

        "quarter" ->
          Angen.Logging.PersistGameQuarterTask.quarter_so_far()

        "year" ->
          Angen.Logging.PersistGameYearTask.year_so_far()

        _day ->
          Angen.Logging.PersistGameDayTask.today_so_far()
      end

    socket
    |> assign(:data, data)
  end

  defp get_log(%{assigns: %{date: nil}} = socket) do
    socket
    |> assign(:data, nil)
  end

  defp get_log(%{assigns: %{unit: unit, date: date}} = socket) do
    overview =
      case unit do
        "week" ->
          Logging.get_game_week_log(date) |> Map.get(:data)

        "month" ->
          Logging.get_game_month_log(date) |> Map.get(:data)

        "quarter" ->
          Logging.get_game_quarter_log(date) |> Map.get(:data)

        "year" ->
          Logging.get_game_year_log(date) |> Map.get(:data)

        _day ->
          Logging.get_game_day_log(date) |> Map.get(:data)
      end

    socket
    |> assign(:data, overview)
  end
end
