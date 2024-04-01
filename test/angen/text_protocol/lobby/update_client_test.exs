defmodule Angen.TextProtocol.Lobby.UpdateClientTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "update client" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/update_client", command: %{player?: true}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/update_client")
    end

    test "no lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/update_client", command: %{player?: true}})
      msg = listen(socket)
      assert_failure(msg, "lobby/update_client", "Must be in a lobby")
    end

    test "correctly" do
      %{socket: _hsocket, lobby_id: lobby_id} = lobby_host_connection()
      %{socket: socket, user_id: user_id} = auth_connection()

      Api.add_client_to_lobby(user_id, lobby_id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/update_client", command: %{player?: true}})
      msg = listen(socket)
      assert_success(msg, "lobby/update_client")

      msg = listen(socket)

      assert msg == %{
               "message" => %{
                 "changes" => %{"player?" => true, "update_id" => 2},
                 "reason" => "self_update",
                 "user_id" => user_id
               },
               "name" => "connections/client_updated"
             }
    end
  end
end
