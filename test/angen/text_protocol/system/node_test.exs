defmodule Angen.TextProtocol.System.NodeTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "node test" do
    test "basic" do
      %{socket: socket} = raw_connection()
      this_node = Node.self() |> to_string

      speak(socket, %{name: "system/nodes", command: %{}})
      msg = listen(socket)

      assert msg == %{
               "name" => "system/nodes",
               "message" => %{
                 "nodes" => [
                   this_node
                 ]
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("system/nodes_message.json", msg["message"])
    end
  end
end
