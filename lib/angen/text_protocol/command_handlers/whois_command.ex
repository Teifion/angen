defmodule Angen.TextProtocol.CommandHandlers.Whois do
  @moduledoc """
  Example usage

  # Failure
  {"command":"whois","id":0}

  # Success
  {"command":"whois","id":1}
  {"command":"whois","name":"teifion"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "whois"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"id" => id}, state) do
    case Api.get_user_by_id(id) do
      nil ->
        FailureResponse.generate("No user by that ID", state)

      user ->
        TextProtocol.WhoisResponse.generate(user, state)
    end
  end

  def handle(%{"name" => name}, state) do
    case Api.get_user_by_name(name) do
      nil ->
        FailureResponse.generate("No user by that name", state)

      user ->
        TextProtocol.WhoisResponse.generate(user, state)
    end
  end
end
