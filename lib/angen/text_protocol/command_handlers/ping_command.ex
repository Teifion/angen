defmodule Angen.TextProtocol.CommandHandlers.Ping do
  @moduledoc """
  Example usage
  {"command": "ping","message-id":123}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec command :: String.t()
  def command, do: "ping"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_msg, state) do
    TextProtocol.PingResponse.generate(:success, :ok, state)
  end
end
