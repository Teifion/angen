defmodule Angen.TextProtocol.InfoHandlers.NoopLog do
  @moduledoc """
  Used when you don't want to actually do anything with the message except log it.
  """
  use Angen.TextProtocol.InfoMacro
  require Logger

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(message, state) do
    Logger.info(
      "Noop handler: message:#{inspect(message, pretty: true)}, state:#{inspect(Map.drop(state, [:socket]), pretty: true)}"
    )

    {nil, state}
  end
end
