defmodule Angen.TextProtocol.Account.RevokeTokensCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro
  alias Angen.Account.UserTokenLib

  @impl true
  @spec name :: String.t()
  def name, do: "account/revoke_tokens"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{}, state) do
    # First, delete the tokens themselves
    UserTokenLib.delete_user_tokens(state.user_id)

    # Now disconnect all connections
    Teiserver.Connections.disconnect_user(state.user_id)

    # Delay a bit just so we don't accidentally send anything
    # in theory what we just did should result in this process dying
    # mid-function call
    :timer.sleep(50)

    # This probably won't make it...
    SuccessResponse.generate(name(), state)
  end
end
