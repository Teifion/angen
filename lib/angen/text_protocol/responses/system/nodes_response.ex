defmodule Angen.TextProtocol.System.NodesResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/nodes"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(node_list, state) do
    result = %{
      "nodes" => Enum.map(node_list, &to_string/1)
    }

    {result, state}
  end
end
