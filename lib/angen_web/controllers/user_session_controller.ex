defmodule AngenWeb.UserSessionController do
  use AngenWeb, :controller

  alias Teiserver.Account
  alias AngenWeb.UserAuth

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
