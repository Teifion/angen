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
      conn =
        post(conn, ~p"/api/request_token", %{
          "id" => "2b4a1c1e-67dc-4e03-bc4a-393d82a722c5",
          "password" => "bad-pass",
          "user_agent" => "agent"
        })

      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad authentication"}
    end

    test "bad password", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/request_token", %{
          "id" => user.id,
          "password" => "bad-pass",
          "user_agent" => "agent"
        })

      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad authentication"}
    end

    test "no agent", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/api/request_token", %{"id" => user.id, "password" => "password"})
      assert json_response(conn, 500) == %{"result" => "Error", "reason" => "Bad parameters"}
    end

    test "good auth", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/request_token", %{
          "id" => user.id,
          "password" => "password",
          "user_agent" => "agent"
        })

      response = json_response(conn, 201)

      assert response["result"] == "Token"
      assert response["token"]["user_id"] == user.id
      assert Map.has_key?(response["token"], "identifier_code")
      assert Map.has_key?(response["token"], "renewal_code")
      assert Map.has_key?(response["token"], "expires_at")

      token = Angen.Account.get_user_token_by_identifier(response["token"]["identifier_code"])
      assert token.user_id == user.id
    end
  end

  describe "renewing" do
    test "bad renewal code", %{conn: conn} do
      user = user_fixture()
      token_code = get_api_token_code(user: user)
      token = Angen.Account.get_user_token_by_identifier(token_code)

      token_list = Angen.Account.list_user_tokens(where: [user_id: user.id])
      assert token_list == [token]

      # Now attempt renewal
      conn = put_req_header(conn, "authorization", "Bearer #{token_code}")
      conn = post(conn, ~p"/api/renew_token", %{"renewal" => "123"})

      response = json_response(conn, 500)
      assert response == %{"result" => "Error", "reason" => "No token"}
    end

    test "no identifier code", %{conn: conn} do
      user = user_fixture()
      token_code = get_api_token_code(user: user)
      token = Angen.Account.get_user_token_by_identifier(token_code)

      token_list = Angen.Account.list_user_tokens(where: [user_id: user.id])
      assert token_list == [token]

      # Now attempt renewal
      conn = post(conn, ~p"/api/renew_token", %{"renewal" => token.renewal_code})

      response = response(conn, 401)
      assert response == "Unauthorised"
    end

    test "bad identifier code", %{conn: conn} do
      user = user_fixture()
      token_code = get_api_token_code(user: user)
      token = Angen.Account.get_user_token_by_identifier(token_code)

      token_list = Angen.Account.list_user_tokens(where: [user_id: user.id])
      assert token_list == [token]

      # Now attempt renewal
      conn = put_req_header(conn, "authorization", "Bearer 123")
      conn = post(conn, ~p"/api/renew_token", %{"renewal" => token.renewal_code})

      response = response(conn, 401)
      assert response == "Unauthorised"
    end

    test "correctly done", %{conn: conn} do
      user = user_fixture()
      token_code = get_api_token_code(user: user)
      token = Angen.Account.get_user_token_by_identifier(token_code)

      token_list = Angen.Account.list_user_tokens(where: [user_id: user.id])
      assert token_list == [token]

      # Now attempt renewal
      conn = put_req_header(conn, "authorization", "Bearer #{token_code}")
      conn = post(conn, ~p"/api/renew_token", %{"renewal" => token.renewal_code})

      response = json_response(conn, 201)
      assert response["result"] == "Token"
      assert response["token"]["user_id"] == user.id
      assert Map.has_key?(response["token"], "identifier_code")
      assert Map.has_key?(response["token"], "renewal_code")
      assert Map.has_key?(response["token"], "expires_at")

      token = Angen.Account.get_user_token_by_identifier(response["token"]["identifier_code"])
      assert token.user_id == user.id

      # Ensure old one is deleted
      old_token = Angen.Account.get_user_token_by_identifier(token_code)
      assert old_token == nil
    end
  end

  describe "using" do
    test "no token", %{conn: conn} do
      payload = %{"name" => "no-token"}

      conn =
        post(conn, ~p"/api/events/simple_clientapp", %{"_json" => payload})

      response = response(conn, 401)
      assert response == "Unauthorised"
    end

    test "bad token", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Bearer 123")

      payload = %{"name" => "bad-token"}

      conn =
        post(conn, ~p"/api/events/simple_clientapp", %{"_json" => payload})

      response = response(conn, 401)
      assert response == "Unauthorised"
    end

    test "good token", %{conn: conn} do
      token = get_api_token_code()
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      payload = %{"name" => "good-token"}

      conn =
        post(conn, ~p"/api/events/simple_clientapp", %{"_json" => payload})

      response = json_response(conn, 201)
      assert response == %{"result" => "Event(s) created", "count" => 1}
    end
  end
end
