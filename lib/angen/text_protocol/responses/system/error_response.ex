defmodule Angen.TextProtocol.ErrorResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "error"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(message, state) do
    result = %{
      "message" => message
    }

    {result, state}
  end
end
