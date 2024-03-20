defmodule AngenWeb.General.HomeLiveTest do
  @moduledoc false
  use AngenWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Anon" do
    # test "index", %{conn: conn} do
    #   {:error, {:redirect, resp}} = live(conn, ~p"/")

    #   assert resp == %{
    #            flash: %{"error" => "You must log in to access this page."},
    #            to: ~p"/login"
    #          }
    # end

    test "index", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Login"
      refute html =~ "Logout"
    end
  end

  describe "Admin Auth" do
    setup [:admin_auth]

    test "index", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      refute html =~ "Login"
      assert html =~ "Logout"
      assert html =~ "Admin"
    end
  end

  describe "Standard Auth" do
    setup [:auth]

    test "index", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      refute html =~ "Login"
      assert html =~ "Logout"
      refute html =~ "Admin"
    end
  end
end
