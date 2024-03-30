defmodule Angen.TextProtocol.CommunicationTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "send_direct_message" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{
        name: "communication/send_direct_message",
        command: %{to_id: "123", content: "123"}
      })

      msg = listen(socket)

      assert_auth_failure(msg, "communication/send_direct_message")
    end

    test "auth" do
      %{socket: socket1, user: user1} = auth_connection()
      %{socket: socket2, user: user2} = auth_connection()

      # Bad target first
      speak(socket1, %{
        name: "communication/send_direct_message",
        command: %{to_id: Teiserver.uuid(), content: ""}
      })

      msg = listen(socket1)
      assert_failure(msg, "communication/send_direct_message", "No user by that ID")

      # Now good ID
      speak(socket1, %{
        name: "communication/send_direct_message",
        command: %{to_id: user2.id, content: "Test message"}
      })

      msg = listen(socket1)

      assert_success(msg, "communication/send_direct_message")

      # User2 should see it
      msg = listen(socket2)

      dm = Teiserver.Communication.get_direct_message(nil, sender_id: user1.id, to_id: user2.id)
      timestamp = dm.inserted_at |> Jason.encode!() |> Jason.decode!()

      assert msg == %{
               "name" => "communication/received_direct_message",
               "message" => %{
                 "message" => %{
                   "content" => "Test message",
                   "delivered?" => false,
                   "sender_id" => user1.id,
                   "inserted_at" => timestamp,
                   "read?" => false,
                   "to_id" => user2.id
                 }
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("communication/received_direct_message.json", msg["message"])
    end
  end
end
