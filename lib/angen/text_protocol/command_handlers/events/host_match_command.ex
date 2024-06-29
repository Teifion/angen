defmodule Angen.TextProtocol.Events.HostMatchCommand do
  @moduledoc false

  alias Angen.Telemetry
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "events/host_match"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(_, %{match_id: nil} = state) do
    FailureResponse.generate({name(), "Must be in an ongoing match"}, state)
  end

  def handle(_, %{lobby_host?: false} = state) do
    FailureResponse.generate({name(), "Must be the host of the lobby"}, state)
  end

  def handle(%{"details" => _} = cmd, state) do
    event = Telemetry.log_complex_match_event(cmd["event"], state.match_id, cmd["user_id"], cmd["game_seconds"], cmd["details"])

    case event do
      :ok ->
        SuccessResponse.generate(name(), state)

      {:error, _reason} ->
        FailureResponse.generate({name(), "Error storing event"}, state)
    end
  end

  def handle(cmd, state) do
    event = Telemetry.log_simple_match_event(cmd["event"], state.match_id, cmd["user_id"], cmd["game_seconds"])

    case event do
      :ok ->
        SuccessResponse.generate(name(), state)

      {:error, _reason} ->
        FailureResponse.generate({name(), "Error storing event"}, state)
    end
  end
end
