defmodule Angen.TextProtocol.CommandHandlers.Connection.Whoami do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connection/whoami"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "You are not logged in"}, state)
  end

  def handle(_, state) do
    user = Api.get_user_by_id(state.user_id)
    TextProtocol.Connection.YouareResponse.generate(user, state)
  end
end
