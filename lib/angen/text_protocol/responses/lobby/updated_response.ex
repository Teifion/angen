defmodule Angen.TextProtocol.Lobby.UpdatedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/updated"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(changes, state) do
    result = %{
      "changes" => changes
    }

    {result, state}
  end
end
