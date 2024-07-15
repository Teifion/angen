defmodule AngenWeb.Admin.Account.ShowLive do
  @moduledoc false
  use AngenWeb, :live_view

  alias Angen.Account

  @impl true
  def mount(%{"user_id" => user_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "account")
      |> assign(:user_id, user_id)
      |> get_user

    if socket.assigns.user do
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/accounts")}
    end
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "account")
     |> assign(:user_id, nil)
     |> assign(:user, nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_user(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_user(%{assigns: %{user_id: user_id}} = socket) do
    user =
      try do
        Account.get_user_by_id(user_id)
      rescue
        _ in Ecto.Query.CastError ->
          nil
      end

    socket
    |> assign(:user, user)
  end
end
