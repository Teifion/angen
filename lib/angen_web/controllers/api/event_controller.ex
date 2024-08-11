defmodule AngenWeb.Api.EventController do
  @moduledoc false
  use AngenWeb, :controller
  alias Angen.Telemetry

  action_fallback AngenWeb.FallbackController

  @spec simple_anon(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def simple_anon(conn, _params) do
    event_count =
      conn
      |> get_json_from_body
      |> List.wrap()
      |> Enum.map(fn event ->
        case Telemetry.log_simple_anon_event(
               event["name"],
               Map.get(event, "hash", Teiserver.uuid())
             ) do
          :ok -> 1
          _err -> 0
        end
      end)
      |> Enum.sum()

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  @spec complex_anon(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def complex_anon(conn, _params) do
    event_count =
      conn
      |> get_json_from_body
      |> List.wrap()
      |> Enum.map(fn event ->
        case Telemetry.log_complex_anon_event(
               event["name"],
               Map.get(event, "hash", Teiserver.uuid()),
               event["details"]
             ) do
          :ok -> 1
          _err -> 0
        end
      end)
      |> Enum.sum()

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  @spec simple_clientapp(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def simple_clientapp(conn, _params) do
    event_count =
      conn
      |> get_json_from_body
      |> List.wrap()
      |> Enum.map(fn event ->
        case Telemetry.log_simple_clientapp_event(
               event["name"],
               Map.get(event, "user_id", conn.assigns.user_id)
             ) do
          :ok -> 1
          _err -> 0
        end
      end)
      |> Enum.sum()

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  @spec complex_clientapp(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def complex_clientapp(conn, _params) do
    event_count =
      conn
      |> get_json_from_body
      |> List.wrap()
      |> Enum.map(fn event ->
        case Telemetry.log_complex_clientapp_event(
               event["name"],
               Map.get(event, "user_id", conn.assigns.user_id),
               event["details"]
             ) do
          :ok -> 1
          _err -> 0
        end
      end)
      |> Enum.sum()

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  @spec simple_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def simple_match(conn, %{"match_id" => match_id}) do
    event_count =
      conn
      |> get_json_from_body
      |> List.wrap()
      |> Enum.map(fn event ->
        case Telemetry.log_simple_match_event(
               event["name"],
               match_id,
               Map.get(event, "user_id", conn.assigns.user_id),
               event["seconds"]
             ) do
          :ok -> 1
          _err -> 0
        end
      end)
      |> Enum.sum()

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  @spec complex_match(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def complex_match(conn, %{"match_id" => match_id}) do
    event_count =
      conn
      |> get_json_from_body
      |> List.wrap()
      |> Enum.map(fn event ->
        case Telemetry.log_complex_match_event(
               event["name"],
               match_id,
               Map.get(event, "user_id", conn.assigns.user_id),
               event["seconds"],
               event["details"]
             ) do
          :ok -> 1
          _err -> 0
        end
      end)
      |> Enum.sum()

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  # Bruno sends a request such that it appears in conn.body_params["_json"] but
  # tests put it straight into body_params. While we have changed it to manually
  # be in _json in the tests it is important to note other sources might do things
  # differently and thus we want to use this
  defp get_json_from_body(%{body_params: %{"_json" => json}} = _conn), do: json
  defp get_json_from_body(%{body_params: json} = _conn), do: json
end
