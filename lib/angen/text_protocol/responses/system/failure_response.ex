defmodule Angen.TextProtocol.FailureResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/failure"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({command_name, reason}, state) do
    result = %{
      "command" => command_name,
      "reason" => reason
    }

    {result, state}
  end
end
