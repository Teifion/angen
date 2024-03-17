defmodule Angen.TextProtocol.InfoHandlers.LobbyUpdated do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.UpdatedResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{changes: changes}, state) do
    UpdatedResponse.generate(changes, state)
  end
end
