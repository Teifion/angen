defmodule Angen.TextProtocol.CommandHandlers.Message do
  @moduledoc """
  Example usage
  {"command":"clients"}
  """

  alias Teiserver.{Account, Communication}
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "message"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"to" => to_name, "content" => content} = msg, state) do
    case Account.get_user_by_name(to_name) do
      nil ->
        FailureResponse.generate("No user found for name #{to_name}", state)

      to_user ->
        Communication.send_direct_message(state.user_id, to_user.id, content)
        TextProtocol.MessageResponse.generate(msg, state)
    end
  end
end
