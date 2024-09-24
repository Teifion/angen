defmodule AngenWeb.Admin.Lobby.IndexLive do
  @moduledoc false
  use AngenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:site_menu_active, "lobbies")
    |> assign(:search_term, "")
    |> assign(:filters, %{})
    |> get_lobbies
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "lobbies")
     |> assign(:lobbies, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_lobbies
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_lobbies(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_lobbies(%{assigns: assigns} = socket) do
    lobbies =
      Teiserver.stream_lobby_summaries(assigns.filters)
      |> Enum.take(30)
      |> Enum.sort_by(fn l -> l.name end, &<=/2)

    socket
    |> assign(:lobbies, lobbies)
  end
end
