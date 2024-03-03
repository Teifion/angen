defmodule Angen.TextProtocol.PongResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "pong"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(_, state) do
    result = %{}

    {result, state}
  end
end
