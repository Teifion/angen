defmodule Angen.TextProtocol.System.IntegrationDataTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.TextProtocol.System.IntegrationDataResponse
  use Angen.DevSupport.BotMacro

  describe "integration test" do
    test "not enabled" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "system/integration_data", command: %{}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/failure",
               "message" => %{
                 "command" => "system/integration_data",
                 "reason" => "Integration not active"
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])
    end

    test "forced response" do
      state = dummy_conn_state()
      bot1 = BotLib.get_or_create_bot_account("IntTestBot1")
      bot2 = BotLib.get_or_create_bot_account("IntTestBot2")
      bot3 = BotLib.get_or_create_bot_account("IntTestBot3")

      {result, _new_state} = IntegrationDataResponse.generate(:ok, state)

      assert result == %{
               "message" => %{
                 "bots" => [
                   %{"id" => bot1.id, "name" => "IntTestBot1"},
                   %{"id" => bot2.id, "name" => "IntTestBot2"},
                   %{"id" => bot3.id, "name" => "IntTestBot3"}
                 ]
               },
               "name" => "system/integration_data"
             }
    end
  end
end
