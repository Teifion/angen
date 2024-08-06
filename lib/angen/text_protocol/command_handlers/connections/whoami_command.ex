defmodule Angen.TextProtocol.CommandHandlers.Connections.Whoami do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connections/whoami"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "You are not logged in"}, state)
  end

  def handle(_, state) do
    user = Teiserver.get_user_by_id(state.user_id)
    client = Teiserver.get_client(state.user_id)
    TextProtocol.Connections.YouareResponse.generate({user, client}, state)
  end
end
