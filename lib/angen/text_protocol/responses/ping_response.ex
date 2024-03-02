defmodule Angen.TextProtocol.PingResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(_, _, state) do
    result = %{
      "command" => "pong"
    }

    {result, state}
  end
end
