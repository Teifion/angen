defmodule Angen.TextProtocol.InfoHandlers.LobbyClosed do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.ClosedResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{lobby_id: lobby_id}, state) do
    ClosedResponse.generate(lobby_id, state)
  end
end
