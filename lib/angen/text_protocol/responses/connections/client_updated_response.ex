defmodule Angen.TextProtocol.Connections.ClientUpdatedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connections/client_updated"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(%Teiserver.Connections.Client{} = client, state) do
    result = %{
      client: TypeConvertors.convert(client)
    }

    {result, state}
  end
end
