defmodule AngenWeb.Admin.Account.IndexLive do
  @moduledoc false
  use AngenWeb, :live_view

  alias Angen.Account

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "account")
      |> get_users

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "account")
     |> assign(:users, [])}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_users(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_users(%{assigns: assigns} = socket) do
    users = Account.list_users(order_by: "Newest first")

    socket
    |> assign(:users, users)
  end
end
