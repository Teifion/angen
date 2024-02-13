defmodule Angen.TextProtocol.ErrorResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(_, message, state) do
    result = %{
      "command" => "n/a",
      "result" => "error",
      "message" => message
    }

    {result, state}
  end
end
