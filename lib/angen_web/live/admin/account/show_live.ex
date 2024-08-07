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
      |> assign(:client, Teiserver.get_client(user_id))
      |> get_user

    if socket.assigns.user do
      :ok = Teiserver.subscribe(Teiserver.Connections.ClientLib.client_topic(user_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/accounts")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "account")
    |> assign(:user_id, nil)
    |> assign(:user, nil)
    |> assign(:client, nil)
    |> ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(
        %{topic: "Teiserver.Connections.Client:" <> _, event: :client_updated} = msg,
        socket
      ) do
    new_client = socket.assigns.client |> Map.merge(msg.changes)

    socket
    |> assign(:client, new_client)
    |> noreply
  end

  def handle_info(%{topic: "Teiserver.Connections.Client:" <> _}, socket) do
    socket
    |> noreply()
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:edit_mode, true)
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:edit_mode, false)
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
