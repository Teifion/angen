defmodule Angen.TextProtocol.ClientTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "update client" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "connections/update_client", command: %{afk?: true}})
      msg = listen(socket)

      assert_auth_failure(msg, "connections/update_client")
    end

    test "no changes" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "connections/update_client", command: %{}})
      msg = listen(socket)

      assert_failure(msg, "connections/update_client", "No changes")
    end

    test "auth'd update" do
      %{socket: socket, user_id: user_id} = auth_connection()

      speak(socket, %{name: "connections/update_client", command: %{
        afk?: true,
        ready?: true,
        in_game?: true,
        sync: %{"key" => 100}
      }})
      # First, success
      msg = listen(socket)
      assert_success(msg, "connections/update_client")

      # Now the result of the update
      msg = listen(socket)
      assert msg == %{
        "message" => %{
          "changes" => %{
            "afk?" => true,
            "ready?" => true,
            "in_game?" => true,
            "sync" => %{"key" => 100},
            "update_id" => 1
          },
          "reason" => "self_update",
          "user_id" => user_id
        },
        "name" => "connections/client_updated"
      }

      # Now test we only get updates based on what we change
      speak(socket, %{name: "connections/update_client", command: %{
        afk?: false,
        ready?: true,
        in_game?: true,
        sync: %{"key" => 100}
      }})
      # First, success
      msg = listen(socket)
      assert_success(msg, "connections/update_client")

      # Now the result of the update
      msg = listen(socket)
      assert msg == %{
        "message" => %{
          "changes" => %{
            "afk?" => false,
            "update_id" => 2
          },
          "reason" => "self_update",
          "user_id" => user_id
        },
        "name" => "connections/client_updated"
      }

      # And the system ignores keys we can't change
      speak(socket, %{name: "connections/update_client", command: %{
        ready?: false,
        lobby_host?: true
      }})

      # First, success
      msg = listen(socket)
      assert_success(msg, "connections/update_client")

      # Now the result of the update
      msg = listen(socket)
      assert msg == %{
        "message" => %{
          "changes" => %{
            "ready?" => false,
            "update_id" => 3
          },
          "reason" => "self_update",
          "user_id" => user_id
        },
        "name" => "connections/client_updated"
      }

      # Finally we request changes but nothing actually changes
      # so we get a success but nothing else
      msg = listen(socket)
      assert msg == :timeout
    end
  end
end
