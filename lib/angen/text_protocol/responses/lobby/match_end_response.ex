defmodule Angen.TextProtocol.Lobby.MatchEndResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/match_end"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({lobby_id, match_id}, state) do
    result = %{
      lobby_id: lobby_id,
      match_id: match_id
    }

    {result, state}
  end
end
