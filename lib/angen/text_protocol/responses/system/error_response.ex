defmodule Angen.TextProtocol.ErrorResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/error"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(reason, state) do
    result = %{
      "reason" => reason
    }

    {result, state}
  end
end
