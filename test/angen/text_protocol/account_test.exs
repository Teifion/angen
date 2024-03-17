defmodule Angen.TextProtocol.AccountTest do
  @moduledoc false
  use Angen.ProtoCase

  describe "whois" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "account/whois", command: %{ids: ["123"]}})
      msg = listen(socket)

      assert_auth_failure(msg, "account/whois")
    end

    test "auth" do
      %{socket: socket, user: user} = auth_connection()

      # Bad ID first
      speak(socket, %{name: "account/whois", command: %{ids: [Teiserver.uuid()]}})
      msg = listen(socket)

      assert msg == %{
               "name" => "account/user_info",
               "message" => %{
                 "users" => []
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("account/user_info_message.json", msg["message"])

      # Now good ID
      speak(socket, %{name: "account/whois", command: %{ids: [user.id]}})
      msg = listen(socket)

      assert msg == %{
               "name" => "account/user_info",
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
      assert JsonSchemaHelper.valid?("account/user_info_message.json", msg["message"])

      # Good and bad
      speak(socket, %{name: "account/whois", command: %{ids: [Teiserver.uuid(), user.id]}})
      msg = listen(socket)

      assert msg == %{
               "name" => "account/user_info",
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
      assert JsonSchemaHelper.valid?("account/user_info_message.json", msg["message"])
    end
  end
end
