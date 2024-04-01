defmodule Angen.TextProtocol.DisconnectTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "disconnect" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "connections/disconnect", command: %{}})
      msg = listen(socket)

      assert_success(msg, "connections/disconnect")

      assert listen(socket) == :closed
    end

    test "auth'd - 1 connection" do
      %{socket: socket, user_id: user_id} = auth_connection()

      speak(socket, %{name: "connections/disconnect", command: %{}})
      msg = listen(socket)

      assert_success(msg, "connections/disconnect")

      assert listen(socket) == :closed
      refute Teiserver.Connections.client_exists?(user_id)
    end

    test "auth'd - 2 connections" do
      user = create_test_user()
      %{socket: socket1} = auth_connection(user)
      %{socket: socket2} = auth_connection(user)

      speak(socket1, %{name: "connections/disconnect", command: %{}})
      msg = listen(socket1)

      assert_success(msg, "connections/disconnect")

      assert listen(socket1) == :closed
      assert listen(socket2) == :timeout
      assert Teiserver.Connections.client_exists?(user.id)
    end
  end
end
