defmodule AngenWeb.Api.EventController do
  @moduledoc false
  use AngenWeb, :controller
  alias AngenWeb.UserAuth
  alias Angen.TextProtocol.TypeConvertors

  action_fallback AngenWeb.FallbackController

  @spec create_event(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_event(conn, params) do
    raise "Not implemented"
  end
end
