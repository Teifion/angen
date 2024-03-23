defmodule Angen.TextProtocol.System.NodesCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/nodes"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{}, state) do
    nodes = [Node.self() | Node.list()]

    TextProtocol.System.NodesResponse.generate(nodes, state)
  end
end
