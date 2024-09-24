defmodule AngenWeb.Admin.Lobby.ShowLive do
  @moduledoc false
  use AngenWeb, :live_view

  @impl true
  def mount(%{"lobby_id" => lobby_id}, _session, socket) when is_connected?(socket) do
    :ok = Teiserver.subscribe_to_lobby(lobby_id)

    socket =
      socket
      |> assign(:site_menu_active, "lobbies")
      |> assign(:lobby_id, lobby_id)
      |> assign(:client, Teiserver.get_client(lobby_id))
      |> assign(:user_cache, %{})
      |> get_lobby
      |> get_other_data

    if socket.assigns.lobby do
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/lobby")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "lobbies")
    |> assign(:lobby_id, nil)
    |> assign(:lobby, nil)
    |> assign(:client, nil)
    |> ok
  end

  @impl true
  @spec handle_info(map(), Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_info(%{event: :lobby_user_left}, socket) do
    noreply(socket)
  end

  def handle_info(%{event: :lobby_client_change, changes: %{lobby_id: nil}}, socket) do
    noreply(socket)
  end

  def handle_info(%{event: :lobby_user_joined}, socket) do
    socket
    |> get_lobby
    |> get_other_data
    |> noreply
  end

  def handle_info(%{event: :lobby_updated}, socket) do
    socket
    |> get_lobby
    |> get_other_data
    |> noreply
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_event("kick-user", %{"user_id" => user_id}, socket) do
    Teiserver.remove_client_from_lobby(user_id, socket.assigns.lobby_id)

    socket
    |> noreply
  end

  @spec get_lobby(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_lobby(%{assigns: %{lobby_id: lobby_id}} = socket) do
    lobby = Teiserver.get_lobby(lobby_id)

    socket
    |> assign(:lobby, lobby)
  end

  @spec get_other_data(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_other_data(%{assigns: %{lobby: nil}} = socket) do
    socket
    |> assign(:host, nil)

    # |> assign(:complex_events, [])
  end

  defp get_other_data(%{assigns: %{lobby: lobby}} = socket) do
    members =
      lobby.members
      |> Enum.map(fn user_id -> Teiserver.get_client(user_id) end)
      |> Enum.sort_by(fn m -> m.team_number end, &<=/2)

    host = Teiserver.get_client(lobby.host_id)

    socket
    |> assign(:host, host)
    |> assign(:members, members)
    |> update_caches
  end

  defp update_caches(%{assigns: %{lobby: lobby, user_cache: user_cache}} = socket) do
    new_user_cache =
      [lobby.host_id | lobby.members]
      |> Map.new(fn user_id ->
        {user_id, Map.get(user_cache, user_id, Teiserver.get_user_by_id(user_id))}
      end)

    new_user_cache = Map.merge(user_cache, new_user_cache)

    socket
    |> assign(:user_cache, new_user_cache)
  end
end
