defmodule Angen.TextProtocol.Lobby.MessagingTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  setup _ do
    close_all_lobbies()
  end

  describe "messaging" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/send_message", command: %{content: "Test content"}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/send_message")
    end

    test "no lobby" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/send_message", command: %{content: "Test content"}})
      msg = listen(socket)

      assert_failure(msg, "lobby/send_message", "Not in a lobby")
    end
  end

  describe "with lobby" do
    setup do
      lobby_host_connection()
    end

    test "empty message", %{socket: socket} do
      speak(socket, %{name: "lobby/send_message", command: %{content: ""}})
      msg = listen(socket)

      assert_failure(
        msg,
        "lobby/send_message",
        "There was an error changing your details: content: can't be blank"
      )
    end

    test "good command", %{socket: socket, user_id: user_id, lobby_id: lobby_id} do
      match_id = Api.get_lobby(lobby_id) |> Map.get(:match_id)

      speak(socket, %{name: "lobby/send_message", command: %{content: "Test content"}})
      # First, success
      msg = listen(socket)

      assert_success(msg, "lobby/send_message")

      # Query it in the DB
      [match_message] = Teiserver.Communication.list_match_messages(where: [match_id: match_id])

      # 2nd, we should now hear our own message
      msg = listen(socket)

      assert msg == %{
               "name" => "lobby/message_received",
               "message" => %{
                 "lobby_id" => lobby_id,
                 "message" => %{
                   "content" => "Test content",
                   "match_id" => match_id,
                   "sender_id" => user_id,
                   "inserted_at" => Jason.encode!(match_message.inserted_at) |> Jason.decode!()
                 }
               }
             }
    end
  end
end
