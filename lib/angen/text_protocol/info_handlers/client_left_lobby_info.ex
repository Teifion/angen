defmodule Angen.TextProtocol.InfoHandlers.ClientLeftLobby do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(msg, state) do
    if msg.user_id == state.user_id do
      Teiserver.Api.unsubscribe_from_lobby(msg.lobby_id)
    end

    nil_response(state)
  end
end
