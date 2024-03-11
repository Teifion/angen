defmodule Angen.TextProtocol.Lobby.QueryTest do
  @moduledoc false
  use Angen.ProtoCase

  setup _ do
    close_all_lobbies()
  end

  describe "no lobbies" do
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
        require_any_tags: ["a", "b"],
        require_all_tags: ["a", "b"],
        exclude_tags: ["z", "x"],
        passworded?: true,
        locked?: true,
        public?: true,
        # match_type: ["1", "2"],
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

  describe "basics with lobbies" do
    setup _ do
      %{socket: host1, lobby: lobby1} = lobby_host_connection()
      %{socket: host2, lobby: lobby2} = lobby_host_connection()
      %{socket: host3, lobby: lobby3} = lobby_host_connection()

      %{socket: socket} = auth_connection()

      %{
        host1: host1,
        lobby1: lobby1,
        host2: host2,
        lobby2: lobby2,
        host3: host3,
        lobby3: lobby3,
        socket: socket
      }
    end

    test "no filters", args do
      %{lobby1: lobby1, lobby2: lobby2, lobby3: lobby3, socket: socket} = args

      speak(socket, %{name: "lobby/query", command: %{filters: %{}}})
      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      assert Enum.member?(ids, lobby1.id)
      assert Enum.member?(ids, lobby2.id)
      assert Enum.member?(ids, lobby3.id)
      assert Enum.count(ids) == 3

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])
    end
  end
end
