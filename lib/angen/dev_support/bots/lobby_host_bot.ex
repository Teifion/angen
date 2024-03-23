defmodule Angen.DevSupport.LobbyHostBot do
  @moduledoc """
  Creates an account called `LobbyHostBot` which will host a lobby.
  """
  use Angen.DevSupport.BotMacro
  require Logger

  @interval 5_000

  def handle_info(:startup, state) do
    user = BotLib.get_or_create_bot_account("LobbyHostBot")
    Api.connect_user(user.id)

    send(self(), :tick)
    :timer.send_interval(@interval, :tick)
    {:noreply, %{state | user: user, connected: true, lobby_id: nil}}
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
