defmodule Angen.TextProtocol.InfoHandlers.ClientUpdated do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{client: client}, state) do
    TextProtocol.Connections.ClientUpdatedResponse.generate(client, state)
  end
end
