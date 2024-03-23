defmodule Angen.TextProtocol.InfoHandlers.ClientUpdated do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{changes: changes, reason: reason, user_id: user_id}, state) do
    new_state = if user_id == state.user_id do
      %{state |
        lobby_host?: Map.get(changes, :lobby_host?, state.lobby_host?),
        party_id: Map.get(changes, :party_id, state.party_id),
        lobby_id: Map.get(changes, :lobby_id, state.lobby_id),
        in_game?: Map.get(changes, :in_game?, state.in_game?)
      }
    else
      state
    end

    TextProtocol.Connections.ClientUpdatedResponse.generate({user_id, changes, reason}, new_state)
  end
end
