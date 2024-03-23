defmodule Angen.TextProtocol.Auth.RenewCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro
  alias Angen.Account

  @impl true
  @spec name :: String.t()
  def name, do: "auth/renew"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"identifier_code" => identifier_code, "renewal_code" => renewal_code}, state) do
    case Account.get_user_token_by_identifier_renewal(identifier_code, renewal_code) do
      nil ->
        FailureResponse.generate({name(), "No token"}, state)

      old_token ->
        {:ok, new_token} = Angen.Account.create_user_token(old_token.user_id, "text-protocol", old_token.user_agent, state.ip)

        Account.delete_user_token(old_token)
        TextProtocol.Auth.TokenResponse.generate(new_token, state)
    end
  end
end
