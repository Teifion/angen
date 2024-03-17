defmodule Angen.TextProtocol.Lobby.ChangeTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  setup _ do
    close_all_lobbies()
  end

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
      flush_socket(socket)

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

    test "change 1 thing", %{socket: socket, lobby_id: lobby_id, user: _user} do
      lobby = Teiserver.Api.get_lobby(lobby_id)
      refute lobby.name == "New lobby name (1)"

      speak(socket, %{name: "lobby/change", command: %{name: "New lobby name (1)"}})
      msg = listen(socket)
      assert_success(msg, "lobby/change")

      # Next message should be the updated lobby info
      msg = listen(socket)
      assert listen_all(socket) == []

      assert msg == %{
               "name" => "lobby/updated",
               "message" => %{
                 "changes" => %{
                    "name" => "New lobby name (1)",
                    "update_id" => 2
                }
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/updated_message.json", msg["message"])

      # Check the lobby did indeed update
      lobby = Teiserver.Api.get_lobby(lobby_id)
      assert lobby.name == "New lobby name (1)"
    end

    test "change 3 things", %{socket: socket, lobby_id: lobby_id, user: _user} do
      lobby = Teiserver.Api.get_lobby(lobby_id)
      refute lobby.name == "New lobby name (3)"

      speak(socket, %{name: "lobby/change", command: %{
        name: "New lobby name (3)",
        public?: false,
        password: "123"
      }})
      msg = listen(socket)
      assert_success(msg, "lobby/change")

      # Next message should be the updated lobby info
      msg = listen(socket)
      assert listen_all(socket) == []

      assert msg == %{
               "name" => "lobby/updated",
               "message" => %{
                 "changes" => %{
                  "name" => "New lobby name (3)",
                  "password" => "123",
                  "passworded?" => true,
                  "public?" => false,
                  "update_id" => 2
                }
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/updated_message.json", msg["message"])

      # Check the lobby did indeed update
      lobby = Teiserver.Api.get_lobby(lobby_id)
      assert lobby.name == "New lobby name (3)"

      # Verify the changes in the summary too
      speak(socket, %{name: "lobby/query", command: %{filters: %{}}})
      msg = listen(socket)

      [summary] = msg["message"]["lobbies"]

      assert summary["id"] == lobby.id
      assert summary["passworded?"] == true
      assert summary["name"] == "New lobby name (3)"
    end
  end
end
