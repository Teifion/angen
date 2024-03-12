defmodule Angen.TextProtocol.InfoMacro do
  @moduledoc """
  Apply to handlers with `use Angen.TextProtocol.InfoMacro`
  """
  @callback handle(map(), Angen.ConnState.t()) :: Angen.handler_response()

  defmacro __using__(_opts) do
    quote do
      @behaviour Angen.TextProtocol.InfoMacro

      alias Angen.TextProtocol
      alias Teiserver.Api
      import Angen.TextProtocol.InfoMacro, only: [nil_response: 1]
    end
  end

  @spec nil_response(Angen.ConnState.t()) :: Angen.handler_response()
  def nil_response(state) do
    {nil, state}
  end
end
