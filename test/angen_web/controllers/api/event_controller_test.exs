defmodule AngenWeb.EventControllerTest do
  @moduledoc false
  use AngenWeb.ConnCase

  setup %{conn: conn} do
    user = create_test_user()
    token_code = get_api_token_code(user: user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token_code}")

    {:ok, %{conn: conn, user: user}}
  end

  describe "simple_clientapp" do
    test "good data", %{conn: conn, user: user} do
      user2 = create_test_user()
      events = Angen.Telemetry.list_simple_clientapp_events(where: [user_id: user.id])
      assert Enum.empty?(events)

      payload = [
        %{"name" => "simple_clientapp1"},
        %{"name" => "simple_clientapp2"},
        %{"name" => "simple_clientapp1", "user_id" => user2.id}
      ]

      conn = post(conn, ~p"/api/events/simple_clientapp", %{"_json" => payload})
      response = json_response(conn, 201)
      assert response == %{"result" => "Event(s) created", "count" => 3}

      events = Angen.Telemetry.list_simple_clientapp_events(where: [user_id: user.id])
      assert Enum.count(events) == 2

      events = Angen.Telemetry.list_simple_clientapp_events(where: [])
      assert Enum.count(events) == 3
    end
  end

  describe "complex_clientapp" do
    test "good data", %{conn: conn, user: user} do
      user2 = create_test_user()
      events = Angen.Telemetry.list_simple_clientapp_events(where: [user_id: user.id])
      assert Enum.empty?(events)

      payload = [
        %{"name" => "complex_clientapp1", "details" => %{key: "value"}},
        %{"name" => "complex_clientapp2", "details" => %{key: "value2"}},
        %{"name" => "complex_clientapp1", "user_id" => user2.id, "details" => %{key: "value3"}}
      ]

      conn = post(conn, ~p"/api/events/complex_clientapp", %{"_json" => payload})
      response = json_response(conn, 201)
      assert response == %{"result" => "Event(s) created", "count" => 3}

      events = Angen.Telemetry.list_complex_clientapp_events(where: [user_id: user.id])
      assert Enum.count(events) == 2

      events = Angen.Telemetry.list_complex_clientapp_events(where: [])
      assert Enum.count(events) == 3
    end
  end
end
