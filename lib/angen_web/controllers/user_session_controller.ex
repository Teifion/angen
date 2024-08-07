defmodule AngenWeb.UserSessionController do
  use AngenWeb, :controller

  alias Angen.Account
  alias AngenWeb.UserAuth

  @spec login_from_code(Plug.Conn.t(), map) :: Plug.Conn.t()
  def login_from_code(conn, %{"code" => "fakedata_code"}) do
    # If the token exists, delete it so it no longer exists and make a new one
    token = Account.get_user_token(UUID.uuid5(nil, "root@localhost"))

    agent =
      case List.keyfind(conn.req_headers, "user-agent", 0) do
        {_, agent} -> agent
        _ -> "fake-data"
      end

    {:ok, new_token} =
      Account.create_user_token(
        token.user_id,
        token.context,
        agent,
        conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      )

    Account.delete_user_token(token)

    maybe_login_with_token(conn, new_token.id)
  end

  def login_from_code(conn, %{"code" => code}) do
    case Cachex.get(:one_time_login_code, code) do
      {:ok, nil} ->
        redirect(conn, to: ~p"/guest")

      {:ok, token_id} ->
        maybe_login_with_token(conn, token_id)

      _ ->
        redirect(conn, to: ~p"/guest")
    end
  end

  defp maybe_login_with_token(conn, token_id) do
    token = Account.get_user_token(token_id, preload: [:user], limit: 1)

    case token do
      nil ->
        redirect(conn, to: ~p"/guest")

      token ->
        conn
        |> put_flash(:info, "You are now logged in with a guest account.")
        |> UserAuth.log_in_with_token(token)
    end
  end

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    # |> put_session(:user_return_to, ~p"/users/settings")
    |> put_session(:user_return_to, ~p"/")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    case Account.get_user_by_email(email) do
      nil ->
        # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/login")

      user ->
        if Account.valid_password?(user, password) do
          conn
          |> put_flash(:info, info)
          |> UserAuth.log_in_user(user, user_params)
        else
          conn
          |> put_flash(:error, "Invalid email or password")
          |> put_flash(:email, String.slice(email, 0, 160))
          |> redirect(to: ~p"/login")
        end
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
