defmodule Angen.TextProtocol.CommandHandlers.Whoami do
  @moduledoc """
  Example usage
  {"command":"whoami"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "whoami"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "You are not logged in"}, state)
  end

  def handle(_, state) do
    user = Api.get_user_by_id(state.user_id)
    TextProtocol.YouareResponse.generate(user, state)
  end
end
