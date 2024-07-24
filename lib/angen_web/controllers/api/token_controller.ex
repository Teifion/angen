defmodule AngenWeb.Api.TokenController do
  @moduledoc false
  use AngenWeb, :controller
  alias AngenWeb.UserAuth
  alias Angen.TextProtocol.TypeConvertors

  action_fallback AngenWeb.FallbackController

  @spec request_token(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def request_token(conn, params) do
    case auth_user(conn, params) do
      {:ok, token} ->
        conn
        |> put_status(201)
        |> assign(:token, TypeConvertors.convert(token))
        |> render(:request_token)

      {:error, reason} ->
        conn
        |> put_status(500)
        |> assign(:reason, reason)
        |> render(:simple_error)
    end
  end

  @spec renew_token(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def renew_token(conn, params) do
    raise "Not implemented"
  end

  defp auth_user(conn, %{"id" => id, "password" => password, "user_agent" => user_agent}) do
    case Teiserver.Api.maybe_authenticate_user_by_id(id, password) do
      {:ok, user} ->
        get_token_from_user(conn, user, user_agent)

      {:error, :no_user} ->
        ip = UserAuth.get_ip_from_conn(conn) |> Tuple.to_list() |> Enum.join(".")
        Teiserver.Api.create_anonymous_audit_log(ip, "/api/request_token", %{
          reason: "no_user",
          id: id,
          user_agent: user_agent
        })

        {:error, "Bad authentication"}

      {:error, _} ->
        {:error, "Bad authentication"}
    end
  end

  defp auth_user(_, _) do
    {:error, "Bad parameters"}
  end

  defp get_token_from_user(conn, user, user_agent) do
    ip = UserAuth.get_ip_from_conn(conn) |> Tuple.to_list() |> Enum.join(".")

    case Angen.Account.create_user_token(user.id, "http", user_agent, ip) do
      {:ok, token} ->
        {:ok, token}

      {:error, _changeset} ->
        # errors =
        #   changeset.errors
        #   |> Enum.map_join(", ", fn {key, {message, _}} ->
        #     "#{key}: #{message}"
        #   end)
        # {:error, "There was an error generating the token: #{errors}"}

        {:error, "There was an error generating the token"}
    end
  end
end
