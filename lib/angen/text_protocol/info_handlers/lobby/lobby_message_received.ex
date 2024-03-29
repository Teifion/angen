defmodule Angen.TextProtocol.InfoHandlers.LobbyMessageReceived do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{match_message: message, lobby_id: lobby_id}, state) do
    TextProtocol.Lobby.MessageReceivedResponse.generate({message, lobby_id}, state)
  end
end
