defmodule AngenWeb.TokenControllerTest do
  @moduledoc false
  use AngenWeb.ConnCase
  import Angen.Fixtures.AccountFixtures, only: [user_fixture: 0]

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "requesting" do
    test "no params", %{conn: conn} do
      conn = post(conn, ~p"/api/request_token")
      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad parameters"}
    end

    test "bad id", %{conn: conn} do
      conn = post(conn, ~p"/api/request_token", %{"id" => "2b4a1c1e-67dc-4e03-bc4a-393d82a722c5", "password" => "bad-pass", "user_agent" => "agent"})
      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad authentication"}
    end

    test "bad password", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/api/request_token", %{"id" => user.id, "password" => "bad-pass", "user_agent" => "agent"})
      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad authentication"}
    end

    test "no agent", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/api/request_token", %{"id" => user.id, "password" => "password"})
      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad parameters"}
    end

    test "good auth", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/api/request_token", %{"id" => user.id, "password" => "password", "user_agent" => "agent"})
      response = json_response(conn, 201)
      # assert  == %{"result" => "Error", "reason" => "Bad parameters"}
      assert response["result"] == "Token"
      assert response["token"]["user_id"] == user.id
      assert Map.has_key?(response["token"], "identifier_code")
      assert Map.has_key?(response["token"], "renewal_code")
      assert Map.has_key?(response["token"], "expires_at")

      token = Angen.Account.get_user_token_by_identifier(response["token"]["identifier_code"])
      assert token.user_id == user.id
    end
  end

  describe "using" do
    test "no token", %{conn: conn} do
      conn = post(conn, ~p"/api/events/simple_clientapp", %{"name" => "no-token"})
      response = response(conn, 401)
      assert response == "Unauthorised"
    end

    test "bad token", %{conn: conn} do
      conn = put_req_header(conn, "token", "123")
      conn = post(conn, ~p"/api/events/simple_clientapp", %{"name" => "bad-token"})
      response = response(conn, 401)
      assert response == "Unauthorised"
    end

    test "good token", %{conn: conn} do
      token = get_api_token_code()
      conn = put_req_header(conn, "token", token)

      conn = post(conn, ~p"/api/events/simple_clientapp", %{"name" => "good-token"})
      response = json_response(conn, 201)
      assert response == %{"result" => "Event created"}
    end
  end
end
