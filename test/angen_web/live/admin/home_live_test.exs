defmodule AngenWeb.Admin.HomeLiveTest do
  @moduledoc false
  use AngenWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Anon" do
    test "index", %{conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }
    end
  end

  describe "Admin Auth" do
    setup [:admin_auth]

    test "index", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin")

      assert html =~ "Live dashboard"
    end
  end

  describe "Standard Auth" do
    setup [:auth]

    test "index", %{conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }
    end
  end
end
