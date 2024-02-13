defmodule Angen.TextProtocol.PingResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(_, _, state) do
    result = %{
      "command" => "ping",
      "result" => "success",
      "message" => "pong"
    }

    {result, state}
  end
end
