defmodule AngenWeb.Api.GameController do
  @moduledoc false
  use AngenWeb, :controller
  alias AngenWeb.UserAuth
  alias Angen.TextProtocol.TypeConvertors

  action_fallback AngenWeb.FallbackController

  @spec create_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_match(conn, params) do
    raise "Not implemented"
  end
end
