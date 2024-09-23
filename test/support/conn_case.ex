defmodule AngenWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AngenWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  import Angen.ProtoCase, only: [create_test_user: 0]

  using do
    quote do
      # The default endpoint for testing
      @endpoint AngenWeb.Endpoint

      use AngenWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AngenWeb.ConnCase
      import Angen.ProtoCase, only: [create_test_user: 0]

      alias Angen.Helper.DateTimeHelper
    end
  end

  setup tags do
    Angen.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @spec auth(map()) :: map()
  def auth(data) do
    {:ok, user} =
      Teiserver.Account.create_user(%{
        name: Teiserver.uuid(),
        email: "#{Teiserver.uuid()}@test",
        password: "password",
        groups: [],
        permissions: []
      })

    data
    |> Map.put(:user, user)
    |> log_in_user
  end

  @spec get_api_token_code(nil | list()) :: String.t()
  def get_api_token_code(opts \\ []) do
    user = opts[:user] || create_test_user()

    {:ok, token} =
      Angen.Account.create_user_token(user.id, "web-api-unit-test", "UnitTest", "127.0.0.1")

    token.identifier_code
  end

  @spec admin_auth(map()) :: map()
  def admin_auth(data) do
    {:ok, user} =
      Teiserver.Account.create_user(%{
        name: Teiserver.uuid(),
        email: "#{Teiserver.uuid()}@test",
        password: "password",
        groups: ["admin"],
        permissions: ["admin"]
      })

    data
    |> Map.put(:user, user)
    |> log_in_user
  end

  @spec log_in_user(map()) :: map()
  defp log_in_user(%{conn: conn, user: user} = data) do
    {:ok, token} = Angen.Account.create_user_token(user.id, "test", "test-user", "127.0.0.1")

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session(:user_token, token.identifier_code)

    %{data | conn: conn}
  end

  @spec auth_conn(Plug.Conn.t()) :: map()
  def auth_conn(conn) do
    user = create_test_user()
    token_code = get_api_token_code(user: user)

    conn =
      conn
      |> Plug.Conn.put_req_header("accept", "application/json")
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token_code}")

    %{
      conn: conn,
      user: user,
      token_code: token_code
    }
  end
end
