defmodule Angen.TextProtocol.InfoHandlers.NoopRaise do
  @moduledoc """
  Raise no handler for this message
  """
  use Angen.TextProtocol.InfoMacro
  require Logger

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(message, state) do
    raise "No handler for: message:#{inspect(message, pretty: true)}, state:#{inspect(Map.drop(state, [:socket]), pretty: true)}"
    {nil, state}
  end
end
