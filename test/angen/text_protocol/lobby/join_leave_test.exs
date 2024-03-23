defmodule Angen.TextProtocol.Lobby.JoinLeaveTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  setup _ do
    close_all_lobbies()
  end

  describe "joining - simple" do
    test "bad command" do
      flunk "Not implemented"
    end

    test "good command" do
      flunk "Not implemented"
    end

    test "passworded lobby" do
      flunk "Not implemented"
    end

    test "locked lobby" do
      flunk "Not implemented"
    end
  end

  describe "joining - complex" do
    test "bad command" do
      flunk "Not implemented"
    end

    test "good command" do
      flunk "Not implemented"
    end

    test "passworded lobby" do
      flunk "Not implemented"
    end

    test "locked lobby" do
      flunk "Not implemented"
    end
  end

  describe "leaving" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/leave", command: %{}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/leave")
    end

    test "not in lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/leave", command: %{}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/failure",
               "message" => %{
                 "command" => "lobby/leave",
                 "reason" => "Not in a lobby"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])
    end

    test "correctly" do
      # Setup users and lobby
      %{socket: hsocket, lobby_id: lobby_id} = lobby_host_connection()
      %{socket: usocket1, user_id: user1_id} = auth_connection()
      %{socket: usocket2, user_id: user2_id} = auth_connection()

      Api.add_client_to_lobby(user1_id, lobby_id)

      flush_socket(hsocket)
      flush_socket(usocket1)

      # Now add the 2nd user and ensure the host and member both get updates
      Api.add_client_to_lobby(user2_id, lobby_id)

      messages = hsocket |> listen_all |> group_responses()
      [host_msg] = messages["lobby/user_joined"]
      assert host_msg["message"]["lobby_id"] == lobby_id
      assert host_msg["message"]["client"]["id"] == user2_id

      messages = usocket1 |> listen_all |> group_responses()
      [user_msg] = messages["lobby/user_joined"]

      assert host_msg == user_msg

      flush_socket(hsocket)
      flush_socket(usocket1)
      flush_socket(usocket2)

      # Now user2 leaves
      speak(usocket2, %{name: "lobby/leave", command: %{}})
      messages = usocket2 |> listen_all |> group_responses()

      # Success response to leaving
      [msg] = messages["system/success"]
      assert_success(msg, "lobby/leave")

      # Client state update, it's possible we will get two of these, one as we are the client
      # and another because we are subscribed to the lobby
      [msg | _] = messages["connections/client_updated"]
      assert msg == %{
        "message" => %{
          "changes" => %{
            "lobby_id" => nil,
            "update_id" => 2
          },
          "user_id" => user2_id,
          "reason" => "left_lobby"
        },
        "name" => "connections/client_updated"
      }

      flunk "Now check the members of the lobby received a user_left update"
    end
  end
end
