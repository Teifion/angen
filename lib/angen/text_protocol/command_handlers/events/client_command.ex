defmodule Angen.TextProtocol.Events.ClientCommand do
  @moduledoc false

  alias Angen.Telemetry
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "events/client"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"details" => _} = cmd, state) do
    event = Telemetry.log_complex_clientapp_event(cmd["event"], state.user_id, cmd["details"])

    case event do
      :ok ->
        SuccessResponse.generate(name(), state)

      {:error, _reason} ->
        FailureResponse.generate({name(), "error storing event"}, state)
    end
  end

  def handle(cmd, state) do
    event = Telemetry.log_simple_clientapp_event(cmd["event"], state.user_id)

    case event do
      :ok ->
        SuccessResponse.generate(name(), state)

      {:error, _reason} ->
        FailureResponse.generate({name(), "error storing event"}, state)
    end
  end
end
