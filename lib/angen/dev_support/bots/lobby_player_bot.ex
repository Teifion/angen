defmodule Angen.DevSupport.LobbyPlayerBot do
  @moduledoc """
  Creates an account called `LobbyPlayerBot` which will reply to Direct Messages with a reversed message.

  e.g. if you send "Test Message" it will reply via DM with "egasseM tseT"
  """
  use Angen.DevSupport.BotMacro
  require Logger

  def handle_info(:startup, state) do
    user = BotLib.get_or_create_bot_account("LobbyPlayerBot")
    client = Teiserver.connect_user(user.id)

    if client do
      {:noreply, %{state | user: user, connected: true}}
    else
      :timer.send_after(500, :startup)
      {:noreply, state}
    end
  end

  def handle_info(
        %{event: :message_received, topic: "Teiserver.Communication.User:" <> _} = msg,
        state
      ) do
    dm = msg.direct_message

    echo_content = msg.direct_message.content |> String.reverse()

    Teiserver.send_direct_message(state.user.id, dm.sender_id, echo_content)

    {:noreply, state}
  end

  def handle_info(%{event: :message_sent, topic: "Teiserver.Communication.User:" <> _}, state) do
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end
end
