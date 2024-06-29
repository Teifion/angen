defmodule Angen.TextProtocol.InfoHandlers.MatchStart do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.MatchStartResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{lobby_id: lobby_id, match_id: match_id}, state) do
    MatchStartResponse.generate({lobby_id, match_id}, %{state | match_id: match_id})
  end
end
