defmodule AngenWeb.Api.GameController do
  @moduledoc false
  use AngenWeb, :controller

  action_fallback AngenWeb.FallbackController

  @create_keys ~w(id name tags public? rated? type game_name game_version team_count team_size player_count)

  @update_keys ~w(winning_team ended_normally? lobby_opened_at match_started_at match_ended_at match_duration_seconds)

  @spec create_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_match(conn, params) do
    attrs =
      params
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
  def update_match(conn, %{"id" => id} = params) do
    match = Teiserver.Game.get_match!(id)

    attrs =
      params
      |> Map.take(@create_keys ++ @update_keys)

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
end
