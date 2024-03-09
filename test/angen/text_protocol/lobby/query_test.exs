defmodule Angen.TextProtocol.Lobby.QueryTest do
  @moduledoc false
  use Angen.ProtoCase

  describe "basics" do
    test "unauth" do
      %{socket: socket} = raw_connection()

      speak(socket, %{name: "lobby/query", command: %{filters: %{}}})
      msg = listen(socket)

      assert_auth_failure(msg, "lobby/query")
    end

    test "no lobbies, no filters" do
      %{socket: socket} = auth_connection()

      speak(socket, %{name: "lobby/query", command: %{filters: %{}}})
      msg = listen(socket)

      assert msg == %{
               "name" => "lobby/list",
               "message" => %{
                 "lobbies" => []
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])
    end

    test "no lobbies, every filter" do
      %{socket: socket} = auth_connection()

      filters = %{
        match_ongoing?: true,
        require_tags: ["a", "b"],
        exclude_tags: ["z", "x"],
        passworded?: true,
        locked?: true,
        public?: true,
        match_type: ["1", "2"],
        rated?: true,
        game_version: "abc",
        game_name: "zxy",
        min_player_count: 1,
        max_player_count: 10
      }

      speak(socket, %{name: "lobby/query", command: %{filters: filters}})
      msg = listen(socket)

      assert msg == %{
               "name" => "lobby/list",
               "message" => %{
                 "lobbies" => []
               }
             }

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])
    end
  end
end
