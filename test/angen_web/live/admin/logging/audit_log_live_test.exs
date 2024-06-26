defmodule AngenWeb.Admin.Logging.AuditLogLiveTest do
  @moduledoc false
  alias Angen.Fixtures.LoggingFixtures
  use AngenWeb.ConnCase

  import Phoenix.LiveViewTest

  defp create_audit(_) do
    audit = LoggingFixtures.audit_log_fixture(%{})
    %{audit: audit}
  end

  describe "Anon" do
    setup [:create_audit]

    test "index", %{conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/logging/audit")

      assert resp == %{
               flash: %{"error" => "You must log in to access this page."},
               to: ~p"/login"
             }
    end
  end

  describe "Standard Auth" do
    setup [:auth, :create_audit]

    test "index", %{conn: conn} do
      {:error, {:redirect, resp}} = live(conn, ~p"/admin/logging/audit")

      assert resp == %{
               flash: %{"error" => "You do not have permission to view that page."},
               to: ~p"/"
             }
    end
  end

  describe "Index" do
    setup [:admin_auth, :create_audit]

    test "lists all audit", %{conn: conn, audit: audit} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/logging/audit")

      assert html =~ "Listing Audit logs"
      assert html =~ audit.ip
    end
  end

  describe "Show" do
    setup [:admin_auth, :create_audit]

    test "displays audit", %{conn: conn, audit: audit_log} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/logging/audit/#{audit_log}")

      assert html =~ "Audit Log ##{audit_log.id}"
      assert html =~ audit_log.ip
    end
  end
end
