defmodule Angen.TextProtocol.CommandHandlers.Clients do
  @moduledoc """
  Example usage
  {"command":"clients"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec command :: String.t()
  def command, do: "clients"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_msg, state) do
    local_client_ids = Teiserver.Connections.list_local_client_ids()
    global_client_ids = Teiserver.Connections.list_client_ids()
    TextProtocol.ClientsResponse.generate(:success, {local_client_ids, global_client_ids}, state)
  end
end
