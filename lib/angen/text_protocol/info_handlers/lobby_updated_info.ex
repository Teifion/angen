defmodule Angen.TextProtocol.InfoHandlers.LobbyUpdated do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.UpdatedResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{lobby: lobby}, state) do
    UpdatedResponse.generate(lobby, state)
  end
end
