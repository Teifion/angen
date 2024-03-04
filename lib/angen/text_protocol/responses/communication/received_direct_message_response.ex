defmodule Angen.TextProtocol.Communication.ReceivedDirectMessageResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "communication/received_direct_message"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(%Teiserver.Communication.DirectMessage{} = direct_message, state) do
    result = %{
      "message" => TypeConvertors.convert(direct_message)
    }

    {result, state}
  end
end
