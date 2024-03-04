defmodule Angen.TextProtocol.CommandHandlers.Ping do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/ping"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_msg, state) do
    TextProtocol.PongResponse.generate(:ok, state)
  end
end
