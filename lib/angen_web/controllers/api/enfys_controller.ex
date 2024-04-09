defmodule AngenWeb.Api.EnfysController do
  use AngenWeb, :controller

  action_fallback AngenWeb.FallbackController

  @spec start(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def start(conn, _params) do
    conn
    |> put_status(201)
    |> assign(:result, %{up: true})
    |> render(:start)
  end
end
