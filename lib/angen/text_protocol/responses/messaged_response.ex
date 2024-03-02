defmodule Angen.TextProtocol.MessagedResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(:success | :failure, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(:success, message, state) do
    data = TypeConvertors.convert(message)

    result = %{
      "command" => "messaged",
      "message" => data
    }

    {result, state}
  end
end
