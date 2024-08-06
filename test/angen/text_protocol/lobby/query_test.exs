defmodule Angen.TextProtocol.Lobby.QueryTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

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
      %{socket: host1, lobby_id: lobby1_id} = lobby_host_connection()
      %{socket: host2, lobby_id: lobby2_id} = lobby_host_connection()
      %{socket: host3, lobby_id: lobby3_id} = lobby_host_connection()

      %{socket: socket} = auth_connection()

      %{
        host1: host1,
        lobby1_id: lobby1_id,
        host2: host2,
        lobby2_id: lobby2_id,
        host3: host3,
        lobby3_id: lobby3_id,
        socket: socket
      }
    end

    test "no filters", args do
      %{lobby1_id: lobby1_id, lobby2_id: lobby2_id, lobby3_id: lobby3_id, socket: socket} = args

      speak(socket, %{name: "lobby/query", command: %{filters: %{}}})
      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      assert Enum.member?(ids, lobby1_id)
      assert Enum.member?(ids, lobby2_id)
      assert Enum.member?(ids, lobby3_id)
      assert Enum.count(ids) == 3

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])
    end

    test "basic match_ongoing?", args do
      %{lobby1_id: lobby1_id, lobby2_id: lobby2_id, lobby3_id: lobby3_id, socket: socket} = args

      Teiserver.update_lobby(lobby1_id, %{match_ongoing?: false})
      Teiserver.update_lobby(lobby2_id, %{match_ongoing?: false})
      Teiserver.update_lobby(lobby3_id, %{match_ongoing?: true})

      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            match_ongoing?: false
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      assert Enum.member?(ids, lobby1_id)
      assert Enum.member?(ids, lobby2_id)
      refute Enum.member?(ids, lobby3_id)
      assert Enum.count(ids) == 2

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])
    end

    test "basic tags", args do
      %{lobby1_id: lobby1_id, lobby2_id: lobby2_id, lobby3_id: lobby3_id, socket: socket} = args

      Teiserver.update_lobby(lobby1_id, %{tags: ["tag1", "tag2"]})
      Teiserver.update_lobby(lobby2_id, %{tags: ["tag2", "tag3"]})
      Teiserver.update_lobby(lobby3_id, %{tags: ["tag3", "tag4"]})

      # Require all (positive)
      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            require_all_tags: ["tag1", "tag2"]
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      assert Enum.member?(ids, lobby1_id)
      refute Enum.member?(ids, lobby2_id)
      refute Enum.member?(ids, lobby3_id)
      assert Enum.count(ids) == 1

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])

      # Require all (negative)
      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            require_all_tags: ["tag1", "tag3"]
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      refute Enum.member?(ids, lobby1_id)
      refute Enum.member?(ids, lobby2_id)
      refute Enum.member?(ids, lobby3_id)
      assert Enum.empty?(ids)

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])

      # Require any (positive)
      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            require_any_tags: ["tag1", "tag2"]
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      assert Enum.member?(ids, lobby1_id)
      assert Enum.member?(ids, lobby2_id)
      refute Enum.member?(ids, lobby3_id)
      assert Enum.count(ids) == 2

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])

      # Require any (negative)
      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            require_any_tags: ["tag5", "tag6"]
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      refute Enum.member?(ids, lobby1_id)
      refute Enum.member?(ids, lobby2_id)
      refute Enum.member?(ids, lobby3_id)
      assert Enum.empty?(ids)

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])

      # Exclude (positive)
      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            exclude_tags: ["tag1", "tag2"]
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      refute Enum.member?(ids, lobby1_id)
      refute Enum.member?(ids, lobby2_id)
      assert Enum.member?(ids, lobby3_id)
      assert Enum.count(ids) == 1

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])

      # Exclude (negative)
      speak(socket, %{
        name: "lobby/query",
        command: %{
          filters: %{
            exclude_tags: ["tag5", "tag6"]
          }
        }
      })

      msg = listen(socket)

      assert Map.has_key?(msg["message"], "lobbies")
      lobbies = msg["message"]["lobbies"]

      ids = lobbies |> Enum.map(fn l -> l["id"] end)

      assert Enum.member?(ids, lobby1_id)
      assert Enum.member?(ids, lobby2_id)
      assert Enum.member?(ids, lobby3_id)
      assert Enum.count(ids) == 3

      assert JsonSchemaHelper.valid?("response.json", msg)
      assert JsonSchemaHelper.valid?("lobby/list_message.json", msg["message"])
    end
  end
end
