defmodule AngenWeb.Admin.Game.IndexLive do
  @moduledoc false
  use AngenWeb, :live_view

  alias Teiserver.Game

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_matches
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> assign(:matches, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_matches
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_matches(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_matches(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    matches =
      Game.list_matches(
        where: [
          started?: true,
          name_like: assigns.search_term
        ],
        preload: [:type],
        order_by: order_by,
        limit: 50
      )

    socket
    |> assign(:matches, matches)
  end
end
