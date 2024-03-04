defmodule Angen.TextProtocol.ConnTest do
  @moduledoc false
  use Angen.ProtoCase

  describe "ping" do
    test "valid unauth ping" do
      %{socket: socket} = raw_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{name: "ping", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "pong",
        "message" => %{},
        "message_id" => id
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("pong_message.json", msg["message"])
    end

    test "valid auth'd ping" do
      %{socket: socket} = auth_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{name: "ping", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "pong",
        "message" => %{},
        "message_id" => id
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("pong_message.json", msg["message"])
    end
  end

  describe "whoami" do
    test "unauth whoami" do
      %{socket: socket} = raw_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{name: "whoami", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "failure",
        "message" => %{
          "command" => "whoami",
          "reason" => "You are not logged in"
        },
        "message_id" => id
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("pong_message.json", msg["message"])
    end

    test "auth'd whoami" do
      %{socket: socket, user: user} = auth_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{name: "whoami", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "youare",
        "message" => %{
          "user" => %{
            "id" => user.id,
            "name" => user.name
          }
        },
        "message_id" => id
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("pong_message.json", msg["message"])
    end
  end

  describe "bad requests" do
    test "invalid request name" do
      %{socket: socket} = raw_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{name: "pong", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "error",
        "message" => %{
          "reason" => "Invalid request schema: {:error, [{\"Value is not allowed in enum.\", \"#/name\"}]}"
        }
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("error_message.json", msg["message"])
    end

    test "invalid request structure" do
      %{socket: socket} = raw_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{gnome: "ping", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "error",
        "message" => %{
          "reason" => "Invalid request schema: {:error, [{\"Required property name was not present.\", \"#\"}]}"
        }
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("error_message.json", msg["message"])
    end

    test "invalid command structure" do
      %{socket: socket} = raw_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{name: "login", message_id: id, command: %{}})
      msg = listen(socket)

      assert msg == %{
        "name" => "error",
        "message" => %{
          "reason" => "Invalid command schema: {:error, [{\"Required properties name, password were not present.\", \"#\"}]}"
        }
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("error_message.json", msg["message"])
    end
  end
end
