defmodule AngenWeb.Api.GameController do
  @moduledoc false
  use AngenWeb, :controller

  action_fallback AngenWeb.FallbackController

  @create_keys ~w(id name tags public? rated? type game_name game_version team_count team_size player_count)

  @update_keys ~w(winning_team ended_normally? lobby_opened_at match_started_at match_ended_at match_duration_seconds)

  @spec create_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_match(conn, _params) do
    attrs =
      conn
      |> get_json_from_body
      |> Map.take(@create_keys)
      |> Map.put("host_id", Angen.Account.get_or_create_anonymous_user().id)
      |> get_type

    case Teiserver.Game.create_match(attrs) do
      {:ok, match} ->
        conn
        |> put_status(201)
        |> assign(:id, match.id)
        |> render(:create_success)

      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> render(:create_failure)
    end
  end

  @spec update_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update_match(conn, _params) do
    attrs =
      conn
      |> get_json_from_body
      |> Map.take(@create_keys ++ @update_keys)
      |> get_type

    match = Teiserver.Game.get_match!(attrs["id"])

    case Teiserver.Game.update_match(match, attrs) do
      {:ok, _match} ->
        conn
        |> put_status(201)
        |> render(:update_success)

      {:error, _changeset} ->
        conn
        |> put_status(500)
        |> render(:update_failure)
    end
  end

  defp get_type(%{"type" => type} = params) do
    type_id = Teiserver.Game.get_or_create_match_type(type).id
    Map.put(params, "type_id", type_id)
  end

  defp get_type(params), do: params

  # Bruno sends a request such that it appears in conn.body_params["_json"] but
  # tests put it straight into body_params. While we have changed it to manually
  # be in _json in the tests it is important to note other sources might do things
  # differently and thus we want to use this
  defp get_json_from_body(%{body_params: %{"_json" => json}} = _conn), do: json
  defp get_json_from_body(%{body_params: json} = _conn), do: json
end
