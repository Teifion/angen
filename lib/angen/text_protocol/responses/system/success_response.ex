defmodule Angen.TextProtocol.SuccessResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/success"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(command_name, state) do
    result = %{
      "command" => command_name
    }

    {result, state}
  end
end
