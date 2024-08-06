defmodule Angen.TextProtocol.Events.EventSubmitTest do
  @moduledoc false
  use Angen.ProtoCase, async: false
  alias Angen.Telemetry

  @details %{
    "key-string" => "string",
    "key-int" => 123,
    "key-list" => [1, 2, 4],
    "key-map" => %{"sub-key" => "sub-value"}
  }

  describe "anonymous" do
    test "simple" do
      hash_id = Teiserver.uuid()
      assert Enum.empty?(Telemetry.list_simple_anon_events(where: [hash_id: hash_id]))

      %{socket: socket} = raw_connection()

      speak(socket, %{
        name: "events/anonymous",
        command: %{event: Teiserver.uuid(), hash_id: hash_id}
      })

      msg = listen(socket)
      assert_success(msg, "events/anonymous")

      [event] = Telemetry.list_simple_anon_events(where: [hash_id: hash_id])
      assert event.hash_id == hash_id
    end

    test "complex" do
      hash_id = Teiserver.uuid()
      assert Enum.empty?(Telemetry.list_complex_anon_events(where: [hash_id: hash_id]))

      %{socket: socket} = raw_connection()

      speak(socket, %{
        name: "events/anonymous",
        command: %{event: Teiserver.uuid(), hash_id: hash_id, details: @details}
      })

      msg = listen(socket)
      assert_success(msg, "events/anonymous")

      [event] = Telemetry.list_complex_anon_events(where: [hash_id: hash_id])
      assert event.hash_id == hash_id
      assert event.details == @details
    end
  end

  describe "client" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "events/client", command: %{event: Teiserver.uuid()}})
      msg = listen(socket)

      assert_auth_failure(msg, "events/client")
    end

    test "simple" do
      %{socket: socket, user_id: user_id} = auth_connection()
      assert Enum.empty?(Telemetry.list_simple_clientapp_events(where: [user_id: user_id]))

      speak(socket, %{name: "events/client", command: %{event: Teiserver.uuid()}})
      msg = listen(socket)
      assert_success(msg, "events/client")

      [event] = Telemetry.list_simple_clientapp_events(where: [user_id: user_id])
      assert event.user_id == user_id
    end

    test "complex" do
      %{socket: socket, user_id: user_id} = auth_connection()
      assert Enum.empty?(Telemetry.list_complex_clientapp_events(where: [user_id: user_id]))

      speak(socket, %{
        name: "events/client",
        command: %{event: Teiserver.uuid(), details: @details}
      })

      msg = listen(socket)
      assert_success(msg, "events/client")

      [event] = Telemetry.list_complex_clientapp_events(where: [user_id: user_id])
      assert event.user_id == user_id
      assert event.details == @details
    end
  end

  describe "match" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{
        name: "events/match",
        command: %{event: Teiserver.uuid(), game_seconds: 123}
      })

      msg = listen(socket)

      assert_auth_failure(msg, "events/match")
    end

    test "auth - not in lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{
        name: "events/match",
        command: %{event: Teiserver.uuid(), game_seconds: 123}
      })

      msg = listen(socket)

      assert_failure(msg, "events/match", "Must be in an ongoing match")
    end

    test "auth - in lobby" do
      %{socket: socket, user_id: user_id} = auth_connection()
      %{lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      flush_socket(socket)

      speak(socket, %{
        name: "events/match",
        command: %{event: Teiserver.uuid(), game_seconds: 123}
      })

      msg = listen(socket)

      assert_failure(msg, "events/match", "Must be in an ongoing match")
    end

    test "simple" do
      %{socket: socket, user_id: user_id} = auth_connection()
      %{lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      Teiserver.start_match(lobby_id)
      flush_socket(socket)

      assert Enum.empty?(Telemetry.list_simple_match_events(where: [user_id: user_id]))

      speak(socket, %{
        name: "events/match",
        command: %{event: Teiserver.uuid(), game_seconds: 123}
      })

      msg = listen(socket)
      assert_success(msg, "events/match")

      [event] = Telemetry.list_simple_match_events(where: [user_id: user_id])
      assert event.user_id == user_id
    end

    test "complex" do
      %{socket: socket, user_id: user_id} = auth_connection()
      %{lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      Teiserver.start_match(lobby_id)
      flush_socket(socket)

      assert Enum.empty?(Telemetry.list_complex_match_events(where: [user_id: user_id]))

      speak(socket, %{
        name: "events/match",
        command: %{event: Teiserver.uuid(), game_seconds: 123, details: @details}
      })

      msg = listen(socket)
      assert_success(msg, "events/match")

      [event] = Telemetry.list_complex_match_events(where: [user_id: user_id])
      assert event.user_id == user_id
      assert event.details == @details
    end
  end

  describe "match host" do
    test "unauth" do
      %{id: user_id} = create_test_user()
      %{socket: socket} = raw_connection()

      speak(socket, %{
        name: "events/host_match",
        command: %{event: Teiserver.uuid(), game_seconds: 123, user_id: user_id}
      })

      msg = listen(socket)

      assert_auth_failure(msg, "events/host_match")
    end

    test "auth - not in lobby" do
      %{socket: socket, user_id: user_id} = auth_connection()

      speak(socket, %{
        name: "events/host_match",
        command: %{event: Teiserver.uuid(), game_seconds: 123, user_id: user_id}
      })

      msg = listen(socket)

      assert_failure(msg, "events/host_match", "Must be in an ongoing match")
    end

    test "auth - in lobby" do
      %{socket: socket, user_id: user_id} = auth_connection()
      %{lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      flush_socket(socket)

      speak(socket, %{
        name: "events/host_match",
        command: %{event: Teiserver.uuid(), game_seconds: 123, user_id: user_id}
      })

      msg = listen(socket)

      assert_failure(msg, "events/host_match", "Must be in an ongoing match")
    end

    test "auth - not the host" do
      %{socket: socket, user_id: user_id} = auth_connection()
      %{lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      Teiserver.start_match(lobby_id)
      flush_socket(socket)

      speak(socket, %{
        name: "events/host_match",
        command: %{event: Teiserver.uuid(), game_seconds: 123, user_id: user_id}
      })

      msg = listen(socket)

      assert_failure(msg, "events/host_match", "Must be the host of the lobby")
    end

    test "simple" do
      %{user_id: user_id} = auth_connection()
      %{socket: socket, lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      Teiserver.start_match(lobby_id)
      flush_socket(socket)

      assert Enum.empty?(Telemetry.list_simple_match_events(where: [user_id: user_id]))

      speak(socket, %{
        name: "events/host_match",
        command: %{event: Teiserver.uuid(), game_seconds: 123, user_id: user_id}
      })

      msg = listen(socket)
      assert_success(msg, "events/host_match")

      [event] = Telemetry.list_simple_match_events(where: [user_id: user_id])
      assert event.user_id == user_id
    end

    test "complex" do
      %{user_id: user_id} = auth_connection()
      %{socket: socket, lobby_id: lobby_id} = lobby_host_connection()
      Teiserver.add_client_to_lobby(user_id, lobby_id)
      Teiserver.start_match(lobby_id)
      flush_socket(socket)

      assert Enum.empty?(Telemetry.list_complex_match_events(where: [user_id: user_id]))

      speak(socket, %{
        name: "events/host_match",
        command: %{
          event: Teiserver.uuid(),
          game_seconds: 123,
          user_id: user_id,
          details: @details
        }
      })

      msg = listen(socket)
      assert_success(msg, "events/host_match")

      [event] = Telemetry.list_complex_match_events(where: [user_id: user_id])
      assert event.user_id == user_id
      assert event.details == @details
    end
  end
end
