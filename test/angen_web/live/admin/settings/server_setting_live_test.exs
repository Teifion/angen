defmodule AngenWeb.Admin.Settings.ServerSettingLiveTest do
  @moduledoc false
  use AngenWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Anon" do
    test "index", %{conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/settings")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }
    end
  end

  describe "Standard Auth" do
    setup [:auth]

    test "index", %{conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/settings")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }
    end
  end

  describe "Index" do
    setup [:admin_auth]

    test "Long description", %{conn: conn} do
      the_type = Teiserver.Settings.get_server_setting_type("require_tokens_to_persist_ip")

      {:ok, index_live, html} = live(conn, ~p"/admin/settings")

      assert html =~ "Data retention"
      assert html =~ the_type.label
      refute html =~ the_type.description
      assert html =~ String.slice(the_type.description, 0..90)

      html = index_live |> element("#row-#{the_type.key}") |> render_click()

      assert html =~ the_type.description
    end

    test "Change value", %{conn: conn} do
      the_type = Teiserver.Settings.get_server_setting_type("max_age_server_events")
      existing_value = Teiserver.Settings.get_server_setting_value(the_type.key)
      assert existing_value != 123

      {:ok, index_live, html} = live(conn, ~p"/admin/settings")

      assert html =~ "Data retention"
      assert html =~ the_type.label

      index_live |> element("#row-#{the_type.key}") |> render_click()

      assert index_live
             |> form("#setting-temp-form", setting: %{value: "123"})
             |> render_submit()

      # Give it time to invalidate the cache
      :timer.sleep(20)

      new_value = Teiserver.Settings.get_server_setting_value(the_type.key)
      assert new_value == 123

      # Now we do it again since this time it will be updating a row in the DB
      {:ok, index_live, html} = live(conn, ~p"/admin/settings")

      assert html =~ "Data retention"
      assert html =~ the_type.label

      index_live |> element("#row-#{the_type.key}") |> render_click()

      assert index_live
             |> form("#setting-temp-form", setting: %{value: "444"})
             |> render_submit()

      # Give it time to invalidate the cache
      :timer.sleep(20)

      new_value = Teiserver.Settings.get_server_setting_value(the_type.key)
      assert new_value == 444

      # And finally, we delete it
      {:ok, index_live, html} = live(conn, ~p"/admin/settings")

      assert html =~ "Data retention"
      assert html =~ the_type.label

      index_live |> element("#row-#{the_type.key}") |> render_click()

      assert index_live
             |> form("#setting-temp-form", setting: %{value: ""})
             |> render_submit()

      # Give it time to invalidate the cache
      :timer.sleep(20)

      new_value = Teiserver.Settings.get_server_setting_value(the_type.key)
      assert new_value == the_type.default
    end
  end
end
