defmodule AngenWeb.Admin.Logging.HomeLive do
  use AngenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:site_menu_active, "Logging")

    {:ok, socket}
  end
end
