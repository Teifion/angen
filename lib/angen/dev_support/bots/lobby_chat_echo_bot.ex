defmodule Angen.DevSupport.LobbyChatEchoBot do
  @moduledoc """
  Creates an account called `LobbyChatEchoBot` which will wait for the lobby opened by the lobby_host_bot, join it and then echo back any chatted messages not from itself but reversed and with the name of the sender at the front.

  e.g. if you send "Test Message" from "Tef" it will reply via LobbyChat with "Tef: egasseM tseT"
  """
  use Angen.DevSupport.BotMacro
  require Logger

  @interval 3_000

  def handle_info(:startup, state) do
    user = BotLib.get_or_create_bot_account("LobbyChatEchoBot")
    client = Teiserver.connect_user(user.id)

    if client do
      send(self(), :tick)
      :timer.send_interval(@interval, :tick)
      {:noreply, %{state | user: user, connected: true}}
    else
      :timer.send_after(500, :startup)
      {:noreply, state}
    end
  end

  def handle_info(:tick, %{lobby_id: nil} = state) do
    case get_lobby_id() do
      nil ->
        # No lobby found yet, we just wait
        {:noreply, state}

      lobby_id ->
        Teiserver.add_client_to_lobby(state.user.id, lobby_id)
        Teiserver.subscribe_to_lobby(lobby_id)
        {:noreply, %{state | lobby_id: lobby_id}}
    end
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  # Handle the lobby closing
  def handle_info(
        %{topic: "Teiserver.Connections.Client:" <> _, reason: "lobby closed"},
        state
      ) do
    {:noreply, %{state | lobby_id: nil}}
  end

  def handle_info(
        %{topic: "Teiserver.Connections.Client:" <> _},
        state
      ) do
    {:noreply, state}
  end

  def handle_info(
        %{event: :message_received, topic: "Teiserver.Game.Lobby:" <> _} = msg,
        state
      ) do
    if msg.match_message.sender_id != state.user.id do
      content =
        msg.match_message.content
        |> String.reverse()

      name =
        msg.match_message.sender_id
        |> Teiserver.get_user_by_id()
        |> Map.get(:name)

      Teiserver.send_lobby_message(state.user.id, state.lobby_id, "#{name}: #{content}")
    end

    {:noreply, state}
  end

  def handle_info(
        %{topic: "Teiserver.Game.Lobby:" <> _},
        state
      ) do
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  defp get_lobby_id() do
    case Teiserver.get_user_by_name("LobbyHostBot") do
      nil ->
        nil

      user ->
        case Teiserver.get_client(user.id) do
          nil ->
            nil

          client ->
            client.lobby_id
        end
    end
  end
end
