defmodule Angen.TextProtocol.AccountTest do
  @moduledoc false
  use Angen.ProtoCase

  describe "whois" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "account/whois", command: %{id: "123"}})
      msg = listen(socket)

      assert_auth_failure(msg, "account/whois")
    end

    test "auth" do
      %{socket: socket, user: user} = auth_connection()

      # Bad ID first
      speak(socket, %{name: "account/whois", command: %{id: Teiserver.uuid()}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/failure",
               "message" => %{
                 "command" => "account/whois",
                 "reason" => "No user by that ID"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])

      # Now good ID
      speak(socket, %{name: "account/whois", command: %{id: user.id}})
      msg = listen(socket)

      assert msg == %{
               "name" => "account/user_info",
               "message" => %{
                 "user" => %{
                   "id" => user.id,
                   "name" => user.name
                 }
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("account/user_info_message.json", msg["message"])
    end
  end
end
