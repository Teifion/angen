defmodule Angen.TextProtocol.Auth.LoginResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "auth/logged_in"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(user, state) do
    client = Teiserver.Api.get_client(user.id)

    result = %{
      "user" => TypeConvertors.convert(user)
    }

    {result,
     %{
       state
       | user_id: user.id,
         user: user,
         lobby_host?: client.lobby_host?,
         party_id: client.party_id,
         lobby_id: client.lobby_id,
         in_game?: client.in_game?
     }}
  end
end
