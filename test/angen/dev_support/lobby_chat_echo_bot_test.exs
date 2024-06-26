defmodule Angen.DevSupport.LobbyChatEchoBotTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.DevSupport.{LobbyChatEchoBot, ManagerServer}
  alias Angen.DevSupport.BotLib

  describe "echo bot" do
    test "back and forth" do
      close_all_lobbies()

      host_user = BotLib.get_or_create_bot_account("LobbyHostBot")
      %{socket: hsocket, lobby_id: lobby_id} = lobby_host_connection(user: host_user)

      # Create it, give it time to join the lobby
      {:ok, p} = ManagerServer.start_bot(LobbyChatEchoBot, %{})
      send(p, :startup)
      :timer.sleep(500)

      bot_user = Api.get_user_by_name("LobbyChatEchoBot")
      assert bot_user

      # Test it has indeed joined the lobby
      lobby = Api.get_lobby(lobby_id)
      assert Enum.member?(lobby.members, bot_user.id)

      # Have the host "send" a message
      flush_socket(hsocket)
      Api.send_lobby_message(host_user.id, lobby_id, "Test message")

      # We should now hear our own message posted
      self_msg = listen(hsocket)

      assert self_msg["name"] == "lobby/message_received"
      assert self_msg["message"]["message"]["content"] == "Test message"
      assert self_msg["message"]["message"]["sender_id"] == host_user.id

      # And now the reply
      reply_msg = listen(hsocket)

      assert reply_msg["name"] == "lobby/message_received"
      assert reply_msg["message"]["message"]["content"] == "LobbyHostBot: egassem tseT"
      assert reply_msg["message"]["message"]["sender_id"] == bot_user.id

      assert reply_msg["message"]["message"]["match_id"] ==
               self_msg["message"]["message"]["match_id"]

      # Stop the bot manually to prevent it doing something while we tear down the test
      ManagerServer.stop_bot(p)
      :timer.sleep(500)
    end
  end
end
