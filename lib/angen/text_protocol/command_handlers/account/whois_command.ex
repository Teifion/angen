defmodule Angen.TextProtocol.CommandHandlers.Account.Whois do
  @moduledoc """

  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "account/whois"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"id" => id}, state) do
    case Api.get_user_by_id(id) do
      nil ->
        FailureResponse.generate({name(), "No user by that ID"}, state)

      user ->
        TextProtocol.Account.UserInfoResponse.generate(user, state)
    end
  end
end
