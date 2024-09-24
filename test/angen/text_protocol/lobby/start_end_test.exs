defmodule Angen.TextProtocol.Lobby.StartEndTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "starting a match" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/match_start", command: %{}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/match_start")
    end

    test "no lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/match_start", command: %{}})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_start", "Must be in a lobby")
    end

    test "not the host" do
      %{lobby: lobby} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      Teiserver.add_client_to_lobby(user.id, lobby.id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/match_start", command: %{}})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_start", "Must be a lobby host")
    end

    test "already started" do
      %{socket: _p1_socket, user: p1_user} = auth_connection()
      %{socket: socket, user: _host_user, lobby_id: lobby_id} = lobby_host_connection()

      Teiserver.add_client_to_lobby(p1_user.id, lobby_id)
      :ok = Teiserver.update_client_in_lobby(p1_user.id, %{player?: true}, "self_update")
      :timer.sleep(100)
      {:ok, _match} = Teiserver.start_match(lobby_id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/match_start", command: %{}})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_start", "Match has already started")
    end

    test "invalid lobby config - no players" do
      %{socket: _p1_socket, user: p1_user} = auth_connection()
      %{socket: socket, user: _host_user, lobby_id: lobby_id} = lobby_host_connection()

      lobby = Teiserver.get_lobby(lobby_id)
      refute lobby.match_ongoing?

      Teiserver.add_client_to_lobby(p1_user.id, lobby_id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/match_start", command: %{}})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_start", "No players")

      lobby = Teiserver.get_lobby(lobby_id)
      refute lobby.match_ongoing?
    end

    test "correctly" do
      %{socket: _p1_socket, user: p1_user} = auth_connection()
      %{socket: socket, user: _host_user, lobby_id: lobby_id} = lobby_host_connection()

      lobby = Teiserver.get_lobby(lobby_id)
      refute lobby.match_ongoing?

      Teiserver.add_client_to_lobby(p1_user.id, lobby_id)
      Teiserver.update_client_in_lobby(p1_user.id, %{player?: true}, "self_update")
      flush_socket(socket)

      speak(socket, %{name: "lobby/match_start", command: %{}})
      msg = listen(socket)
      assert_success(msg, "lobby/match_start")

      lobby = Teiserver.get_lobby(lobby_id)
      assert lobby.match_ongoing?
    end
  end

  describe "ending a match" do
    defp end_match_properties(user_ids) do
      %{
        "winning_team" => 1,
        "ended_normally?" => true,
        "players" =>
          Map.new(user_ids, fn user_id ->
            {user_id,
             %{
               "left_after_seconds" => 100
             }}
          end)
      }
    end

    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/match_end", command: end_match_properties([])})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/match_end")
    end

    test "no lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/match_end", command: end_match_properties([])})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_end", "Must be in a lobby")
    end

    test "not the host" do
      %{lobby: lobby} = lobby_host_connection()
      %{socket: socket, user: user} = auth_connection()

      Teiserver.add_client_to_lobby(user.id, lobby.id)
      flush_socket(socket)

      speak(socket, %{name: "lobby/match_end", command: end_match_properties([])})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_end", "Must be a lobby host")
    end

    test "not started" do
      %{socket: _p1_socket, user: p1_user} = auth_connection()
      %{socket: socket, user: _host_user, lobby_id: lobby_id} = lobby_host_connection()

      Teiserver.add_client_to_lobby(p1_user.id, lobby_id)
      Teiserver.update_client_in_lobby(p1_user.id, %{player?: true}, "self_update")
      flush_socket(socket)

      speak(socket, %{name: "lobby/match_end", command: end_match_properties([])})
      msg = listen(socket)
      assert_failure(msg, "lobby/match_end", "Match is not currently ongoing")
    end

    test "correctly" do
      %{socket: _p1_socket, user: p1_user} = auth_connection()
      %{socket: socket, user: _host_user, lobby_id: lobby_id} = lobby_host_connection()

      Teiserver.add_client_to_lobby(p1_user.id, lobby_id)
      Teiserver.update_client_in_lobby(p1_user.id, %{player?: true}, "self_update")
      :timer.sleep(100)
      {:ok, _match} = Teiserver.start_match(lobby_id)
      flush_socket(socket)

      lobby = Teiserver.get_lobby(lobby_id)
      assert lobby.match_ongoing?
      match_id = lobby.match_id

      match = Teiserver.get_match(match_id)
      assert match.winning_team == nil
      assert match.ended_normally? == nil
      assert match.match_ended_at == nil
      assert match.match_duration_seconds == nil

      speak(socket, %{name: "lobby/match_end", command: end_match_properties([p1_user.id])})
      msg = listen(socket)
      assert_success(msg, "lobby/match_end")

      lobby = Teiserver.get_lobby(lobby_id)
      refute lobby.match_ongoing?
      assert lobby.match_id != match_id

      match = Teiserver.get_match(match_id)
      assert match.winning_team == 1
      assert match.ended_normally? == true
      assert match.match_ended_at != nil
      assert match.match_duration_seconds != nil
    end
  end
end
