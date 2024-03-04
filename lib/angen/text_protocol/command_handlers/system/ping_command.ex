defmodule Angen.TextProtocol.CommandHandlers.Ping do
  @moduledoc """
  Example usage
  {"command": "ping","message_id":123}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "ping"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_msg, state) do
    TextProtocol.PongResponse.generate(:ok, state)
  end
end
