defmodule Angen.TextProtocol.Lobby.JoinedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/joined"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({shared_secret, lobby}, state) when is_bitstring(shared_secret) do
    result = %{
      "lobby" => TypeConvertors.convert(lobby),
      "shared_secret" => shared_secret
    }

    {result, state}
  end
end
