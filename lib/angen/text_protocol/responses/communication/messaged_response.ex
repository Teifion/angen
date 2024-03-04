defmodule Angen.TextProtocol.MessagedResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "messaged"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(message, state) do
    data = TypeConvertors.convert(message)

    result = %{
      "command" => "messaged",
      "message" => data
    }

    {result, state}
  end
end
