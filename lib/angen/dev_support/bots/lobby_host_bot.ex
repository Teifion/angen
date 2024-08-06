defmodule Angen.DevSupport.LobbyHostBot do
  @moduledoc """
  Creates an account called `LobbyHostBot` which will host a lobby.
  """
  use Angen.DevSupport.BotMacro
  require Logger

  @interval 5_000

  def handle_info(:startup, state) do
    user = BotLib.get_or_create_bot_account("LobbyHostBot")
    client = Teiserver.connect_user(user.id)

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
    lobby_id =
      case Teiserver.open_lobby(state.user.id, "Integration test lobby") do
        {:ok, lobby_id} ->
          lobby_id

        {:error, "Already in a lobby"} ->
          client = Teiserver.get_client(state.user.id)
          client.lobby_id

        {:error, _} ->
          nil
      end

    {:noreply, %{state | lobby_id: lobby_id}}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  def handle_info(%{event: :client_updated, topic: "Teiserver.Connections.Client:" <> _}, state) do
    {:noreply, state}
  end

  def handle_info(
        %{event: :joined_lobby, topic: "Teiserver.Connections.Client:" <> _, lobby_id: lobby_id},
        state
      ) do
    {:noreply, %{state | lobby_id: lobby_id}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end
end
