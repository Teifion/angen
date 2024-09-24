defmodule Angen.DevSupport.LobbyPlayerBot do
  @moduledoc """
  Creates an account called `LobbyPlayerBot` which will try to join the lobby hosted
  by LobbyHostPlayBot and mark itself as a player.
  """
  use Angen.DevSupport.BotMacro
  require Logger

  @interval 5_000

  def handle_info(:startup, state) do
    user = BotLib.get_or_create_bot_account("LobbyPlayerBot#{state.params.idx}")
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

  # def handle_info(
  #       %{event: :message_received, topic: "Teiserver.Communication.User:" <> _} = msg,
  #       state
  #     ) do
  #   dm = msg.direct_message

  #   echo_content = msg.direct_message.content |> String.reverse()

  #   Teiserver.send_direct_message(state.user.id, dm.sender_id, echo_content)

  #   {:noreply, state}
  # end

  def handle_info(
        %{
          event: :client_updated,
          topic: "Teiserver.Connections.Client:" <> _,
          reason: "joined_lobby"
        } = _msg,
        state
      ) do
    {:noreply, state}
  end

  def handle_info(
        %{
          event: :client_updated,
          topic: "Teiserver.Connections.Client:" <> _,
          reason: "left_lobby"
        } = _msg,
        state
      ) do
    {:noreply, %{state | lobby_id: nil}}
  end

  def handle_info(
        %{event: :joined_lobby, topic: "Teiserver.Connections.Client:" <> _} = _msg,
        state
      ) do
    {:noreply, state}
  end

  def handle_info(
        %{event: :left_lobby, topic: "Teiserver.Connections.Client:" <> _} = _msg,
        state
      ) do
    {:noreply, state}
  end

  def handle_info(:tick, %{lobby_id: nil} = state) do
    # Not in a lobby, lets try to find the one we're meant to be in!
    case get_lobby_id() do
      nil ->
        {:noreply, state}

      lobby_id ->
        Teiserver.add_client_to_lobby(state.user.id, lobby_id)
        {:noreply, %{state | lobby_id: lobby_id}}
    end
  end

  def handle_info(:tick, %{lobby_id: _} = state) do
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  defp get_lobby_id() do
    case Teiserver.get_user_by_name("LobbyHostPlayBot") do
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
