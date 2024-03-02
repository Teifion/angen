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
    end
  end
end
