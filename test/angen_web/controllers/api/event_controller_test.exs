defmodule AngenWeb.EventControllerTest do
  @moduledoc false
  use AngenWeb.ConnCase
  import Angen.Fixtures.AccountFixtures, only: [user_fixture: 0]

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "using" do
    test "good token", %{conn: conn} do
      user = create_test_user()
      events = Angen.Telemetry.list_simple_clientapp_events(where: [user_id: user.id])
      assert Enum.empty?(events)

      token = get_api_token_code(user: user)
      conn = post(conn, ~p"/api/events/simple_clientapp", %{"name" => "good-token", "token" => token})
      response = json_response(conn, 201)
      assert response == %{"result" => "Event created"}

      events = Angen.Telemetry.list_simple_clientapp_events(where: [user_id: user.id])
      assert Enum.count(events) == 1
    end
  end
end
