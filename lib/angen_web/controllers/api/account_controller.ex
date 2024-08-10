defmodule AngenWeb.Api.AccountController do
  @moduledoc false
  use AngenWeb, :controller

  action_fallback AngenWeb.FallbackController

  @spec create_user(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_user(conn, %{"name" => _} = params) do
    id = Map.get(params, "id", Teiserver.uuid())

    attrs = %{
      "id" => id,
      "name" => params["name"],
      "email" => "#{Teiserver.uuid()}@angen",
      "password" => Teiserver.Account.generate_password()
    }

    case Teiserver.Account.create_user(attrs) do
      {:ok, user} ->
        conn
        |> put_status(201)
        |> assign(:user, user)
        |> render(:create_success)

      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> render(:create_failure)
    end
  end
end
