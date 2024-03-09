defmodule Angen.TextProtocol.LobbyTest do
  @moduledoc false
  use Angen.ProtoCase

  describe "open" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/open", command: %{name: "OpenLobbyTest"}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/open")
    end

    test "auth" do
      %{socket: socket, user: user} = auth_connection()

      # Bad ID first
      speak(socket, %{name: "lobby/open", command: %{name: ""}})
      msg = listen(socket)

      assert msg == %{
        "name" => "system/failure",
        "message" => %{
          "command" => "lobby/open",
          "reason" => "No name supplied"
        }
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])

      # Now good ID
      speak(socket, %{name: "lobby/open", command: %{name: "my test lobby"}})
      msg = listen(socket)

      lobby = Teiserver.Api.list_lobby_summaries()
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
    test "not a host" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/close", command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "system/failure",
        "message" => %{
          "command" => "lobby/close",
          "reason" => "Not a lobby host"
        }
      }
    end

    test "while a host" do
      %{socket: socket, user: user, lobby: _lobby} = lobby_host_connection()

      # Ensure we appear in the list
      lobby_list = Teiserver.Api.list_lobby_summaries()
        |> Enum.filter(fn l -> l.host_id == user.id end)

      refute Enum.empty?(lobby_list)

      # Now close it
      speak(socket, %{name: "lobby/close", command: %{}})
      msg = listen(socket)

      # We should not appear in the list
      lobby_list = Teiserver.Api.list_lobby_summaries()
        |> Enum.filter(fn l -> l.host_id == user.id end)

      # Check the client
      client = Api.get_client(user.id)
      refute client.lobby_host?

      # Check the message
      assert Enum.empty?(lobby_list)
      assert_success(msg, "lobby/close")
    end
  end
end
