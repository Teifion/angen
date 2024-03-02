defmodule Angen.TextProtocol.ConnTest do
  @moduledoc false
  use AngenWeb.ProtoCase

  describe "ping" do
    test "unauth ping" do
      %{socket: socket} = new_connection()
      id = Ecto.UUID.generate()

      speak(socket, %{command: "ping", message_id: id})
      msg = listen(socket)

      assert msg == %{
               "command" => "pong",
               "message_id" => id
             }
    end
  end
end
