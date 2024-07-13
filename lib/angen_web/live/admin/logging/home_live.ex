defmodule AngenWeb.Admin.Account.HomeLive do
  use AngenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:site_menu_active, "Account")

    {:ok, socket}
  end
end
