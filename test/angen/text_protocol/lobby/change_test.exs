defmodule Angen.TextProtocol.Lobby.ChangeTest do
  @moduledoc false
  use Angen.ProtoCase

  # setup _ do
  #   close_all_lobbies()
  # end

  describe "bad context" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/change", command: %{}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/change")
    end

    test "not in lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/change", command: %{}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/failure",
               "message" => %{
                 "command" => "lobby/change",
                 "reason" => "Must be in a lobby"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])
    end

    test "not a host" do
      %{lobby: lobby} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      Teiserver.Api.add_client_to_lobby(user.id, lobby.id)
      listen_all(socket)

      speak(socket, %{name: "lobby/change", command: %{}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/failure",
               "message" => %{
                 "command" => "lobby/change",
                 "reason" => "Must be a lobby host"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])
    end
  end

  describe "valid" do
    setup do
      lobby_host_connection()
    end

    test "change nothing", %{socket: socket} do
      speak(socket, %{name: "lobby/change", command: %{}})
      msg = listen(socket)

      assert_success(msg, "lobby/change")

      assert listen_all(socket) == []
    end

    test "change 1 thing", %{socket: socket, lobby_id: lobby_id, user: user} do
      lobby = Teiserver.Api.get_lobby(lobby_id)
      refute lobby.name == "New lobby name"

      speak(socket, %{name: "lobby/change", command: %{name: "New lobby name"}})
      msg = listen(socket)
      assert_success(msg, "lobby/change")

      # Next message should be the updated lobby info
      msg = listen(socket)
      assert listen_all(socket) == []

      assert msg == %{
               "name" => "lobby/updated",
               "message" => %{
                 "lobby" => %{
                    "game_name" => nil,
                    "game_settings" => %{},
                    "game_version" => nil,
                    "host_data" => %{},
                    "host_id" => user.id,
                    "id" => lobby_id,
                    "locked?" => false,
                    "match_id" => lobby.match_id,
                    "match_ongoing?" => false,
                    "match_type" => nil,
                    "members" => [],
                    "name" => "New lobby name",
                    "password" => nil,
                    "passworded?" => false,
                    "players" => [],
                    "public?" => true,
                    "queue_id" => nil,
                    "rated?" => true,
                    "spectators" => [],
                    "tags" => []

                 }
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/updated_message.json", msg["message"])

      # Check the lobby did indeed update
      lobby = Teiserver.Api.get_lobby(lobby_id)
      assert lobby.name == "New lobby name"
    end
  end
end
