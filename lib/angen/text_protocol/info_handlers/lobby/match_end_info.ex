defmodule Angen.TextProtocol.InfoHandlers.MatchEnd do
  @moduledoc false
  alias Angen.TextProtocol.Lobby.MatchEndResponse
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{lobby_id: lobby_id, match_id: match_id}, state) do
    MatchEndResponse.generate({lobby_id, match_id}, %{state | match_id: nil})
  end
end
