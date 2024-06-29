defmodule Angen.TextProtocol.Events.AnonymousCommand do
  @moduledoc false

  alias Angen.Telemetry
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "events/anonymous"

  @impl true
  def handle(%{"details" => _} = cmd, state) do
    event = Telemetry.log_complex_anon_event(cmd["event"], cmd["hash_id"], cmd["details"])

    case event do
      :ok ->
        SuccessResponse.generate(name(), state)

      {:error, _reason} ->
        FailureResponse.generate({name(), "Error storing event"}, state)
    end
  end

  def handle(cmd, state) do
    event = Telemetry.log_simple_anon_event(cmd["event"], cmd["hash_id"])

    case event do
      :ok ->
        SuccessResponse.generate(name(), state)

      {:error, _reason} ->
        FailureResponse.generate({name(), "Error storing event"}, state)
    end
  end
end
