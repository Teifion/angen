defmodule AngenWeb.Admin.Account.IndexLive do
  @moduledoc false
  use AngenWeb, :live_view

  alias Angen.Account

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:site_menu_active, "account")
    |> assign(:search_term, "")
    |> get_users
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "account")
     |> assign(:users, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_users
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_users(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_users(%{assigns: assigns} = socket) do
    order_by = if assigns.search_term != "" do
      "Name (A-Z)"
    else
      "Newest first"
    end

    users = Account.list_users(where: [name_like: assigns.search_term], order_by: order_by, limit: 50)

    socket
    |> assign(:users, users)
  end
end
