defmodule AngenWeb.Api.AccountController do
  @moduledoc false
  use AngenWeb, :controller

  action_fallback AngenWeb.FallbackController

  @spec create_user(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_user(conn, _params) do
    params =
      conn
      |> get_json_from_body

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

  # Bruno sends a request such that it appears in conn.body_params["_json"] but
  # tests put it straight into body_params. While we have changed it to manually
  # be in _json in the tests it is important to note other sources might do things
  # differently and thus we want to use this
  defp get_json_from_body(%{body_params: %{"_json" => json}} = _conn), do: json
  defp get_json_from_body(%{body_params: json} = _conn), do: json
end
