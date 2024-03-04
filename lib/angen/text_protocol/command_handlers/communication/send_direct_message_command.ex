defmodule Angen.TextProtocol.CommandHandlers.Communication.SendDirectMessage do
  @moduledoc false

  alias Teiserver.{Account, Communication}
  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "communication/send_direct_message"

  @impl true
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"to_id" => to_id, "content" => content}, state) do
    case Account.get_user_by_id(to_id) do
      nil ->
        FailureResponse.generate({name(), "No user by that ID"}, state)

      to_user ->
        Communication.send_direct_message(state.user_id, to_user.id, content)
        SuccessResponse.generate(name(), state)
    end
  end
end
