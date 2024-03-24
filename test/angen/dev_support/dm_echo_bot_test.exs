defmodule Angen.DevSupport.DMEchoBotTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.DevSupport.{DMEchoBot, ManagerServer}

  describe "echo bot" do
    test "back and forth" do
      close_all_lobbies()

      {:ok, p} = ManagerServer.start_bot(DMEchoBot, %{})
      send(p, :startup)
      :timer.sleep(100)

      bot_user = Api.get_user_by_name("DMEchoBot")
      %{socket: socket, user: user} = auth_connection()

      flush_socket(socket)

      Api.send_direct_message(user.id, bot_user.id, "Test message")

      msg = listen(socket)
      assert msg["name"] == "communication/received_direct_message"
      assert msg["message"]["message"]["content"] == "egassem tseT"
      assert msg["message"]["message"]["from_id"] == bot_user.id
      assert msg["message"]["message"]["to_id"] == user.id

      send(p, :stop)
    end
  end
end
