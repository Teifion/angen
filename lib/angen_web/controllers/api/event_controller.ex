defmodule AngenWeb.Api.EventController do
  @moduledoc false
  use AngenWeb, :controller
  alias Angen.Telemetry

  action_fallback AngenWeb.FallbackController

  @spec simple_clientapp(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def simple_clientapp(conn, %{"name" => name}) do
    Telemetry.log_simple_clientapp_event(name, conn.assigns.user_id)

    conn
    |> put_status(201)
    |> render(:success)
  end
end
