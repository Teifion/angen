defmodule Angen.TextProtocol.ValidationTest do
  @moduledoc false
  use Angen.DataCase
  alias Angen.Helpers.JsonSchemaHelper

  describe "valid schemas" do
    test "ping request" do
      msg = %{
        "name" => "ping",
        "command" => %{},
        "message_id" => "123"
      }

      assert JsonSchemaHelper.valid?("request.json", msg)
      assert JsonSchemaHelper.valid?("system/ping_command.json", msg["command"])
    end

    test "pong response" do
      msg = %{
        "name" => "pong",
        "message" => %{},
        "message_id" => "123"
      }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/pong_message.json", msg["message"])
    end

    test "registered response" do
      msg = %{
        "name" => "registered",
        "message" => %{
          "user" => %{
            "name" => "user name here",
            "id" => "user id here"
          }
        },
        "message_id" => "123"
      }

      assert JsonSchemaHelper.validate("response.json", msg) == :ok
      assert JsonSchemaHelper.validate("account/registered_message.json", msg["message"]) == :ok
    end
  end

  describe "invalid schemas" do
    # test "request - bad name" do
    #   msg = %{
    #     "name" => "pong",
    #     "command" => %{},
    #     "message_id" => "123"
    #   }

    #   refute JsonSchemaHelper.valid?("request.json", msg)
    # end

    test "request - no command" do
      msg = %{
        "name" => "ping",
        "message_id" => "123"
      }

      refute JsonSchemaHelper.valid?("request.json", msg)
    end

    # test "response - bad name" do
    #   msg = %{
    #     "name" => "ping",
    #     "response" => %{},
    #     "message_id" => "123"
    #   }

    #   refute JsonSchemaHelper.valid?("response.json", msg)
    # end

    test "response - no message" do
      msg = %{
        "name" => "registered",
        "message_id" => "123"
      }

      refute JsonSchemaHelper.valid?("response.json", msg)
    end
  end
end
