defmodule Angen.TextProtocol.Lobby.UserJoinedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/user_joined"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({client, lobby_id}, state) do
    result = %{
      "lobby_id" => lobby_id,
      "client" => TypeConvertors.convert(client)
    }

    {result, state}
  end

  def do_generate({client, lobby_id, shared_secret}, state) do
    result = %{
      "lobby_id" => lobby_id,
      "client" => TypeConvertors.convert(client),
      "shared_secret" => shared_secret
    }

    {result, state}
  end
end
