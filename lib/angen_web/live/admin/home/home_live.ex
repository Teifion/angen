defmodule AngenWeb.Admin.HomeLive do
  use AngenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:site_menu_active, "admin")

    {:ok, socket}
  end
end
