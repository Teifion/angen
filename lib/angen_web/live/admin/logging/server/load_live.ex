defmodule AngenWeb.Admin.Logging.Server.LoadLive do
  @moduledoc false
  use AngenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket = socket
      |> assign(:site_menu_active, "logging")

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(_event_text, _event_data, %{assigns: _assigns} = socket) do
    {:noreply, socket}
  end
end
