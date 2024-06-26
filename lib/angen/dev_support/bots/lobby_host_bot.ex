defmodule Angen.DevSupport.LobbyHostBot do
  @moduledoc """
  Creates an account called `LobbyHostBot` which will host a lobby.
  """
  use Angen.DevSupport.BotMacro
  require Logger

  @interval 5_000

  def handle_info(:startup, state) do
    user = BotLib.get_or_create_bot_account("LobbyHostBot")
    client = Api.connect_user(user.id)

    if client do
      send(self(), :tick)
      :timer.send_interval(@interval, :tick)
      {:noreply, %{state | user: user, connected: true, lobby_id: nil}}
    else
      :timer.send_after(500, :startup)
      {:noreply, state}
    end
  end

  def handle_info(:tick, %{lobby_id: nil} = state) do
    {:ok, lobby_id} = Api.open_lobby(state.user.id, "Integration test lobby")

    {:noreply, %{state | lobby_id: lobby_id}}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  def handle_info(%{event: :client_updated, topic: "Teiserver.Connections.Client:" <> _}, state) do
    {:noreply, state}
  end

  def handle_info(%{event: :joined_lobby, topic: "Teiserver.Connections.Client:" <> _}, state) do
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end
end
