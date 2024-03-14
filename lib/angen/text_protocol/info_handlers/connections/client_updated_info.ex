defmodule Angen.TextProtocol.InfoHandlers.ClientUpdated do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{client: client, reason: reason}, state) do
    new_state = if client.id == state.user_id do
      %{state |
        lobby_host?: client.lobby_host?,
        party_id: client.party_id,
        lobby_id: client.lobby_id,
        in_game?: client.in_game?
      }
    else
      state
    end

    TextProtocol.Connections.ClientUpdatedResponse.generate({client, reason}, new_state)
  end
end
