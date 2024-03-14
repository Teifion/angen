defmodule Angen.TextProtocol.Lobby.UserLeftResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/user_left"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({user_id, lobby_id}, state) do
    result = %{
      "user_id" => user_id,
      "lobby_id" => lobby_id
    }

    {result, state}
  end
end
