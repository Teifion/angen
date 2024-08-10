defmodule AngenWeb.Admin.Game.ShowLive do
  @moduledoc false
  use AngenWeb, :live_view

  alias Angen.Game

  @impl true
  def mount(%{"match_id" => match_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:match_id, match_id)
      |> assign(:client, Teiserver.get_client(match_id))
      |> get_match
      |> get_other_data

    if socket.assigns.match do
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:match_id, nil)
    |> assign(:match, nil)
    |> assign(:client, nil)
    |> ok
  end

  # @impl true
  # @spec handle_event(String.t(), map(), Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  # def handle_event("delete-match-token", %{"token_id" => token_id}, socket) do
  #   token = Angen.Game.get_match_token(token_id)
  #   Angen.Game.delete_match_token(token)

  #   socket
  #   |> get_other_data
  #   |> noreply
  # end

  @spec get_match(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_match(%{assigns: %{match_id: match_id}} = socket) do
    match =
      try do
        Teiserver.Game.get_match(match_id,
          preload: [
            :host,
            :members_with_users,
            :type,
            :settings_with_types,
            :choices_with_users_and_types
          ]
        )
      rescue
        _ in Ecto.Query.CastError ->
          nil
      end

    socket
    |> assign(:match, match)
  end

  @spec get_other_data(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_other_data(%{assigns: %{match: nil}} = socket) do
    socket
    |> assign(:simple_events, [])
    |> assign(:complex_events, [])
  end

  defp get_other_data(%{assigns: %{match: match}} = socket) do
    simple_events =
      Angen.Telemetry.list_simple_match_events(
        where: [match_id: match.id],
        preload: [:event_type, :user],
        order_by: "Game times seconds (low to high)"
      )

    complex_events =
      Angen.Telemetry.list_complex_match_events(
        where: [match_id: match.id],
        preload: [:event_type, :user],
        order_by: "Game times seconds (low to high)"
      )

    members =
      match.members
      |> Enum.sort_by(fn m -> m.team_number end, &<=/2)

    socket
    |> assign(:simple_events, simple_events)
    |> assign(:complex_events, complex_events)
    |> assign(:members, members)
  end
end
