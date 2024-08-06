defmodule AngenWeb.Admin.Account.NewLive do
  @moduledoc false
  use AngenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:site_menu_active, "account")
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "account")
     |> assign(:users, [])}
  end
end
