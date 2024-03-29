defmodule Angen.TextProtocol.InfoHandlers.UserJoinedLobby do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.UserJoinedResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{client: client, lobby_id: lobby_id} = msg, state) do
    if state.lobby_host? do
      UserJoinedResponse.generate({client, lobby_id, msg.shared_secret}, state)
    else
      UserJoinedResponse.generate({client, lobby_id}, state)
    end
  end
end
