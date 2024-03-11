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

    test "change nothing", %{socket: socket, lobby: lobby, user: user} do
      speak(socket, %{name: "lobby/change", command: %{}})
      msg = listen(socket)

      assert_success(msg, "lobby/change")

      assert listen_all(socket) == []
    end

    test "change 1 thing", %{socket: socket, lobby: lobby, user: user} do
      speak(socket, %{name: "lobby/change", command: %{name: "New lobby name"}})
      msg = listen(socket)

      assert_success(msg, "lobby/change")

      assert listen_all(socket) == []
    end
  end
end
