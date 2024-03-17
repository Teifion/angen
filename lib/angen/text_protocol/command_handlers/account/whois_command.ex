defmodule Angen.TextProtocol.CommandHandlers.Account.Whois do
  @moduledoc false
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "account/whois"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"ids" => ids}, state) do
    users = Teiserver.Account.list_users(where: [id: ids], limit: 50)

    TextProtocol.Account.UserInfoResponse.generate(users, state)
  end
end
