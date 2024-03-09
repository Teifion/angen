defmodule Angen.TextProtocol.Lobby.ListResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/list"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(lobbies, state) do
    result = %{
      "lobbies" => TypeConvertors.convert(lobbies)
    }

    {result, state}
  end
end
