defmodule AngenWeb.Api.EventController do
  @moduledoc false
  use AngenWeb, :controller
  alias Angen.Telemetry

  action_fallback AngenWeb.FallbackController

  @spec simple_clientapp(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def simple_clientapp(conn, %{"events" => events}) do
    event_count = events
    |> Enum.map(fn event ->
      case Telemetry.log_simple_clientapp_event(event["name"], Map.get(event, "user_id", conn.assigns.user_id)) do
        :ok -> 1
        _err -> 0
      end
    end)
    |> Enum.sum

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end

  @spec complex_clientapp(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def complex_clientapp(conn, %{"events" => events}) do
    event_count = events
    |> Enum.map(fn event ->
      case Telemetry.log_complex_clientapp_event(event["name"], Map.get(event, "user_id", conn.assigns.user_id), event["details"]) do
        :ok -> 1
        _err -> 0
      end
    end)
    |> Enum.sum

    conn
    |> put_status(201)
    |> assign(:count, event_count)
    |> render(:success)
  end
end
