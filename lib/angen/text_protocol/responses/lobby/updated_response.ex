defmodule Angen.TextProtocol.Lobby.UpdatedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/updated"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(lobby, state) do
    result = %{
      "lobby" => TypeConvertors.convert(lobby)
    }

    {result, state}
  end
end
