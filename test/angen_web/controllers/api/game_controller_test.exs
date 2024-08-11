defmodule AngenWeb.GameControllerTest do
  @moduledoc false
  use AngenWeb.ConnCase

  setup %{conn: conn} do
    {:ok, auth_conn(conn)}
  end

  describe "create" do
    test "good data", %{conn: conn} do
      matches = Teiserver.Game.list_matches(where: [name: "MyFirstEverGame"])
      assert Enum.empty?(matches)

      payload = %{
        "name" => "MyFirstEverGame",
        "tags" => ["match-made", "lang-en", "lang-de"],
        "public?" => false,
        "rated?" => true,
        "type" => "team",
        "game_name" => "game-app-name",
        "game_version" => "1.3.12",
        "team_count" => 2,
        "team_size" => 2,
        "player_count" => 4
      }

      conn = post(conn, ~p"/api/game/create_match", %{"_json" => payload})
      response = json_response(conn, 201)

      matches = Teiserver.Game.list_matches(where: [name: "MyFirstEverGame"])
      assert Enum.count(matches) == 1
      [match] = matches

      assert response == %{"result" => "Match created", "id" => match.id}

      assert match.name != "NewMatchNameUpdate"

      payload = %{
        "id" => match.id,
        "name" => "NewMatchNameUpdate"
      }

      conn = post(conn, ~p"/api/game/update_match", %{"_json" => payload})
      response = json_response(conn, 201)
      assert response == %{"result" => "Match updated"}

      match = Teiserver.Game.get_match!(match.id)
      assert match.name == "NewMatchNameUpdate"
    end
  end
end
