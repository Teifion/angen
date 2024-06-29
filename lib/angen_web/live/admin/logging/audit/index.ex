defmodule AngenWeb.Admin.Logging.AuditLogLive.Index do
  use AngenWeb, :live_view

  alias Teiserver.Logging

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    {:ok,
     socket
     |> stream(:audit_logs, Logging.list_audit_logs(order_by: "Newest first", preload: [:user]))
     |> assign(:site_menu_active, "logging")}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:audit_logs, [])
     |> assign(:site_menu_active, "logging")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Audit logs")
    |> assign(:audit_log, nil)
  end
end
