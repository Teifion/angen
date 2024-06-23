defmodule AngenWeb.PageControllerTest do
  @moduledoc false
  use AngenWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/guest")
    assert html_response(conn, 200) =~ "login"
  end
end
