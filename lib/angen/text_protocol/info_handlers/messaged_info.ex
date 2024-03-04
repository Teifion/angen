defmodule Angen.TextProtocol.InfoHandlers.Messaged do
  @moduledoc """

  """
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{direct_message: message}, state) do
    TextProtocol.Communication.ReceivedDirectMessageResponse.generate(message, state)
  end
end
