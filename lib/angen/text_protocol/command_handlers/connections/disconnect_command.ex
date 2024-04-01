defmodule Angen.TextProtocol.Connections.DisconnectCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connections/disconnect"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    send(self(), :disconnect)
    SuccessResponse.generate(name(), state)
  end

  def handle(_, %{user_id: user_id} = state) do
    Teiserver.Connections.disconnect_single_connection(user_id)
    SuccessResponse.generate(name(), state)
  end
end
