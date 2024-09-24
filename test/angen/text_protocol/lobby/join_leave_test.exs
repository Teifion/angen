defmodule Angen.TextProtocol.Lobby.JoinLeaveTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  setup _ do
    close_all_lobbies()
  end

  describe "joining - simple" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/join", command: %{id: Teiserver.uuid()}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/join")
    end

    test "no lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/join", command: %{id: Teiserver.uuid()}})
      msg = listen(socket)
      assert_failure(msg, "lobby/join", "No lobby")
    end

    test "locked" do
      %{socket: _hsocket, lobby_id: lobby_id} = lobby_host_connection()
      %{socket: socket} = auth_connection()

      Teiserver.update_lobby(lobby_id, %{locked?: true})

      speak(socket, %{name: "lobby/join", command: %{id: lobby_id}})
      msg = listen(socket)
      assert_failure(msg, "lobby/join", "Lobby is locked")
    end

    test "good command" do
      %{socket: hsocket, lobby_id: lobby_id} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      flush_socket(hsocket)

      speak(socket, %{name: "lobby/join", command: %{id: lobby_id}})
      messages = socket |> listen_all |> group_responses()

      [msg] = messages["lobby/joined"]
      shared_secret = msg["message"]["shared_secret"]
      assert Map.has_key?(msg["message"], "lobby")

      lobby = Teiserver.get_lobby(lobby_id)
      assert Enum.member?(lobby.members, user.id)

      [msg] = messages["connections/client_updated"]

      assert msg == %{
               "message" => %{
                 "changes" => %{
                   "lobby_id" => lobby_id,
                   "update_id" => 1
                 },
                 "reason" => "joined_lobby",
                 "user_id" => user.id
               },
               "name" => "connections/client_updated"
             }

      messages = hsocket |> listen_all |> group_responses()
      [msg] = messages["lobby/user_joined"]

      assert msg["message"]["shared_secret"] == shared_secret
    end

    test "good command - superfluous password" do
      %{lobby_id: lobby_id} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      speak(socket, %{
        name: "lobby/join",
        command: %{id: lobby_id, password: "no password needed"}
      })

      messages = socket |> listen_all |> group_responses()

      [msg] = messages["lobby/joined"]
      assert Map.has_key?(msg["message"], "shared_secret")
      lobby = Teiserver.get_lobby(lobby_id)
      assert Enum.member?(lobby.members, user.id)

      [msg] = messages["connections/client_updated"]

      assert msg == %{
               "message" => %{
                 "changes" => %{
                   "lobby_id" => lobby_id,
                   "update_id" => 1
                 },
                 "reason" => "joined_lobby",
                 "user_id" => user.id
               },
               "name" => "connections/client_updated"
             }
    end

    test "passworded lobby" do
      %{lobby_id: lobby_id} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      Teiserver.update_lobby(lobby_id, %{password: "password1"})

      # No password given
      speak(socket, %{name: "lobby/join", command: %{id: lobby_id}})
      msg = listen(socket)
      assert_failure(msg, "lobby/join", "Incorrect password")

      # Wrong given
      speak(socket, %{name: "lobby/join", command: %{id: lobby_id, password: "123456"}})
      msg = listen(socket)

      assert_failure(msg, "lobby/join", "Incorrect password")

      # And now the correct password
      speak(socket, %{name: "lobby/join", command: %{id: lobby_id, password: "password1"}})
      messages = socket |> listen_all |> group_responses()

      [msg] = messages["lobby/joined"]
      assert Map.has_key?(msg["message"], "shared_secret")
      lobby = Teiserver.get_lobby(lobby_id)
      assert Enum.member?(lobby.members, user.id)

      [msg] = messages["connections/client_updated"]

      assert msg == %{
               "message" => %{
                 "changes" => %{
                   "lobby_id" => lobby_id,
                   "update_id" => 1
                 },
                 "reason" => "joined_lobby",
                 "user_id" => user.id
               },
               "name" => "connections/client_updated"
             }
    end
  end

  # TODO: These cannot be done until we have the relevant server_settings implemented
  # describe "joining - complex" do
  #   test "unauth" do
  #     Application.put_env(:teiserver, :lobby_join_method, :host_approval)
  #     %{socket: socket} = raw_connection()

  #     speak(socket, %{name: "lobby/join", command: %{id: Teiserver.uuid()}})
  #     msg = listen(socket)

  #     assert_auth_failure(msg, "lobby/join")
  #   end

  #   test "bad command" do
  #     Application.put_env(:teiserver, :lobby_join_method, :host_approval)
  #     flunk "Not implemented"
  #   end

  #   test "good command" do
  #     Application.put_env(:teiserver, :lobby_join_method, :host_approval)
  #     flunk "Not implemented"
  #   end

  #   test "passworded lobby" do
  #     Application.put_env(:teiserver, :lobby_join_method, :host_approval)
  #     flunk "Not implemented"
  #   end

  #   test "locked lobby" do
  #     Application.put_env(:teiserver, :lobby_join_method, :host_approval)
  #     flunk "Not implemented"
  #   end
  # end

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
      assert_failure(msg, "lobby/leave", "Not in a lobby")
    end

    test "correctly" do
      # Setup users and lobby
      %{socket: hsocket, lobby_id: lobby_id} = lobby_host_connection()
      %{socket: usocket1, user_id: user1_id} = auth_connection()
      %{socket: usocket2, user_id: user2_id} = auth_connection()

      Teiserver.add_client_to_lobby(user1_id, lobby_id)

      flush_socket(hsocket)
      flush_socket(usocket1)

      # Now add the 2nd user and ensure the host and member both get updates
      Teiserver.add_client_to_lobby(user2_id, lobby_id)

      messages = hsocket |> listen_all |> group_responses()
      [host_msg] = messages["lobby/user_joined"]
      assert host_msg["message"]["lobby_id"] == lobby_id
      assert host_msg["message"]["client"]["id"] == user2_id

      messages = usocket1 |> listen_all |> group_responses()
      [user_msg] = messages["lobby/user_joined"]

      # The user message should NOT containt the shared_secret, thus they should be different
      assert host_msg["message"] != user_msg["message"]

      # We can verify that's the only difference by simply adding the shared secret
      assert host_msg["message"] ==
               Map.put(user_msg["message"], "shared_secret", host_msg["message"]["shared_secret"])

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

      # And the other members?
      messages = usocket1 |> listen_all |> group_responses()
      [msg | _] = messages["lobby/user_left"]

      assert msg == %{
               "message" => %{
                 "lobby_id" => lobby_id,
                 "user_id" => user2_id
               },
               "name" => "lobby/user_left"
             }

      messages = hsocket |> listen_all |> group_responses()
      [msg | _] = messages["lobby/user_left"]

      assert msg == %{
               "message" => %{
                 "lobby_id" => lobby_id,
                 "user_id" => user2_id
               },
               "name" => "lobby/user_left"
             }
    end
  end
end
