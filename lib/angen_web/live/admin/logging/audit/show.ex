defmodule AngenWeb.Admin.Logging.AuditLogLive.Show do
  use AngenWeb, :live_view

  alias Teiserver.Logging

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:audit_log, Logging.get_audit_log!(id))}
  end

  defp page_title(:show), do: "Show Audit log"
end
