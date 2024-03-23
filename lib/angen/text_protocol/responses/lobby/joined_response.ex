defmodule Angen.TextProtocol.Lobby.JoinedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/joined"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(data, state) do
    result = %{

    }

    {result, state}
  end
end
