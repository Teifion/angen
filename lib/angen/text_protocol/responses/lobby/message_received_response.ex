defmodule Angen.TextProtocol.Lobby.MessageReceivedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/message_received"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({message, lobby_id}, state) do
    result = %{
      "message" => message,
      "lobby_id" => lobby_id
    }

    {result, state}
  end
end
