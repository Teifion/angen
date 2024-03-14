defmodule Angen.TextProtocol.InfoHandlers.UserLeftLobby do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.UserLeftResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{user_id: user_id, lobby_id: lobby_id}, state) do
    UserLeftResponse.generate({user_id, lobby_id}, state)
  end
end
