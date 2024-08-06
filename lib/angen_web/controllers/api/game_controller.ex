defmodule AngenWeb.Api.GameController do
  @moduledoc false
  use AngenWeb, :controller

  action_fallback AngenWeb.FallbackController

  @spec create_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_match(_conn, _params) do
    raise "Not implemented"
  end
end
