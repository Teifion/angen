defmodule AngenWeb.AccountControllerTest do
  @moduledoc false
  use AngenWeb.ConnCase

  setup %{conn: conn} do
    {:ok, auth_conn(conn)}
  end

  describe "create" do
    test "good data", %{conn: conn} do
      users = Teiserver.Account.list_users(where: [name: "MyFirstEverUser"])
      assert Enum.empty?(users)

      payload = %{
        "name" => "MyFirstEverUser"
      }

      conn = post(conn, ~p"/api/account/create_user", %{"_json" => payload})
      response = json_response(conn, 201)

      users = Teiserver.Account.list_users(where: [name: "MyFirstEverUser"])
      assert Enum.count(users) == 1
      [user] = users

      assert response == %{
               "result" => "User created",
               "id" => user.id,
               "name" => "MyFirstEverUser"
             }
    end
  end
end
