defmodule Angen.TextProtocol.Account.UserQueryTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "user query" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "account/user_query", command: %{filters: %{}}})
      msg = listen(socket)

      assert_auth_failure(msg, "account/user_query")
    end

    test "no filters" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "account/user_query", command: %{filters: %{}}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/failure",
               "message" => %{
                 "command" => "account/user_query",
                 "reason" => "Must provide at least 1 filter"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])
    end

    test "filter on IDs" do
      %{socket: socket, user: user} = auth_connection()

      speak(socket, %{name: "account/user_query", command: %{filters: %{id: [user.id, Teiserver.uuid()]}}})
      msg = listen(socket)

      assert msg == %{
               "name" => "account/user_list",
               "message" => %{
                 "users" => [
                    %{
                      "id" => user.id,
                      "name" => user.name
                    }
                 ]
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("account/user_list_message.json", msg["message"])
    end

    test "filter on Name" do
      %{socket: socket, user: user} = auth_connection()

      speak(socket, %{name: "account/user_query", command: %{filters: %{name: user.name}}})
      msg = listen(socket)

      assert msg == %{
               "name" => "account/user_list",
               "message" => %{
                 "users" => [
                    %{
                      "id" => user.id,
                      "name" => user.name
                    }
                 ]
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("account/user_list_message.json", msg["message"])
    end
  end
end
