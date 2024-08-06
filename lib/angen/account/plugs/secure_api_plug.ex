defmodule Angen.Account.SecureApiPlug do
  @moduledoc false
  import Plug.Conn
  alias AngenWeb.UserAuth

  @spec init(list()) :: list()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, _opts) do
    token_code = case get_req_header(conn, "token") do
      [c | _] -> c
      _ -> nil
    end

    case Angen.Account.get_user_token_by_identifier(token_code) do
      nil ->
        fail_auth(conn)
      %Angen.Account.UserToken{} = token ->
        conn
        |> assign(:user_id, token.user_id)
        |> test_ip(token.ip)
    end
  end

  defp test_ip(conn, token_ip) do
    bad_ip = if Teiserver.get_server_setting_value("require_tokens_to_persist_ip") do
      conn_ip = UserAuth.get_ip_from_conn(conn)
      conn_ip != token_ip
    else
      false
    end

    if bad_ip do
      fail_auth(conn)
    else
      conn
    end
  end

  defp fail_auth(conn) do
    conn
    |> resp(401, "Unauthorised")
    |> halt()
  end
end
