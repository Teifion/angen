defmodule Angen.TextProtocol.Lobby.ClosedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/closed"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(lobby_id, state) do
    result = %{
      "lobby_id" => lobby_id
    }

    {result, state}
  end
end
