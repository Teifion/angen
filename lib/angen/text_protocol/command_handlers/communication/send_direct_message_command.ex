defmodule Angen.TextProtocol.CommandHandlers.SendDirectMessage do
  @moduledoc """
  Example usage
  {"command":"clients"}
  """

  alias Teiserver.{Account, Communication}
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "send_direct_message"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"to_id" => to_id, "content" => content}, state) do
    case Account.get_user_by_id(to_id) do
      nil ->
        FailureResponse.generate("No user with that id", state)

      to_user ->
        Communication.send_direct_message(state.user_id, to_user.id, content)
        SuccessResponse.generate(name(), state)
    end
  end
end
