defmodule Angen.TextProtocol.Lobby.OpenCloseTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "open" do
    test "not logged in" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/open", command: %{name: "OpenLobbyTest"}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/open")
    end

    test "already in a lobby" do
      %{lobby: lobby} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      Teiserver.add_client_to_lobby(user.id, lobby.id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/open", command: %{name: "OpenLobbyTest"}})
      msg = listen(socket)

      assert_failure(msg, "lobby/open", "Already in a lobby")
    end

    test "correct" do
      %{socket: socket, user: user} = auth_connection()

      # Bad ID first
      speak(socket, %{name: "lobby/open", command: %{name: ""}})
      msg = listen(socket)
      assert_failure(msg, "lobby/open", "No name supplied")

      # Now good ID
      speak(socket, %{name: "lobby/open", command: %{name: "my test lobby"}})
      msg = listen(socket)

      lobby =
        Teiserver.stream_lobby_summaries()
        |> Enum.filter(fn l -> l.host_id == user.id end)
        |> hd

      assert msg == %{
               "name" => "lobby/opened",
               "message" => %{
                 "lobby_id" => lobby.id
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/opened_message.json", msg["message"])
    end
  end

  describe "close" do
    test "not logged in" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/close", command: %{}})
      msg = listen(socket)
      assert_auth_failure(msg, "lobby/close")
    end

    test "must be in a lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/close", command: %{}})
      msg = listen(socket)
      assert_failure(msg, "lobby/close", "Must be in a lobby")
    end

    test "not a host" do
      %{lobby: lobby} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      Teiserver.add_client_to_lobby(user.id, lobby.id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/close", command: %{}})
      msg = listen(socket)

      assert_failure(msg, "lobby/close", "Must be a lobby host")
    end

    test "while a host" do
      # First we want a socket listening to global news about lobbies
      listener = TestConn.new([Teiserver.Game.LobbyLib.global_lobby_topic()])

      %{socket: socket, user: user, lobby_id: lobby_id} = lobby_host_connection()

      # Ensure we appear in the list
      lobby_list =
        Teiserver.stream_lobby_summaries()
        |> Enum.filter(fn l -> l.host_id == user.id end)

      refute Enum.empty?(lobby_list)

      # Now close it
      speak(socket, %{name: "lobby/close", command: %{}})

      messages =
        socket
        |> listen_all()
        |> group_responses()

      assert Map.has_key?(messages, "connections/client_updated")
      assert Map.has_key?(messages, "system/success")

      # We should not appear in the list
      lobby_list =
        Teiserver.stream_lobby_summaries()
        |> Enum.filter(fn l -> l.host_id == user.id end)

      # Check the client
      client = Teiserver.get_client(user.id)
      refute client.lobby_host?

      # Check the success message
      assert Enum.empty?(lobby_list)
      assert_success(hd(messages["system/success"]), "lobby/close")

      # Check the client updated message
      msg = hd(messages["connections/client_updated"])

      assert msg == %{
               "name" => "connections/client_updated",
               "message" => %{
                 "changes" => %{
                   "lobby_host?" => false,
                   "lobby_id" => nil,
                   "update_id" => 2
                 },
                 "user_id" => user.id,
                 "reason" => "closed lobby"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("connections/client_updated_message.json", msg["message"])

      # Now check our global mailbox
      messages = TestConn.get(listener)

      assert messages == [
               %{
                 event: :lobby_closed,
                 topic: Teiserver.Game.LobbyLib.global_lobby_topic(),
                 lobby_id: lobby_id
               }
             ]
    end

    test "add user and close" do
      %{socket: hsocket, user: _host, lobby_id: lobby_id} = lobby_host_connection()
      %{socket: usocket, user: user} = auth_connection()

      Teiserver.add_client_to_lobby(user.id, lobby_id)

      # Clear the messages
      flush_socket(hsocket)
      flush_socket(usocket)

      speak(hsocket, %{name: "lobby/close", command: %{}})

      # First, host messages
      # we mostly want to ensure we get the closed messages
      messages =
        hsocket
        |> listen_all()
        |> group_responses()

      assert messages["system/success"] == [
               %{"message" => %{"command" => "lobby/close"}, "name" => "system/success"}
             ]

      assert messages["lobby/closed"] == [
               %{"message" => %{"lobby_id" => lobby_id}, "name" => "lobby/closed"}
             ]

      # Now, the user
      messages =
        usocket
        |> listen_all()
        |> group_responses()

      [msg] = messages["lobby/closed"]

      assert msg == %{
               "message" => %{"lobby_id" => lobby_id},
               "name" => "lobby/closed"
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/closed_message.json", msg["message"])
    end
  end
end
