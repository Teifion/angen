defmodule Angen.TextProtocol.ResponseMacro do
  @moduledoc """
  Apply to handlers with `use Angen.TextProtocol.ResponseMacro`
  """
  @callback generate(:success | :failure, any(), Angen.ConnState.t()) :: Angen.handler_response()

  defmacro __using__(_opts) do
    quote do
      @behaviour Angen.TextProtocol.ResponseMacro

      alias Angen.TextProtocol.TypeConvertors
    end
  end
end
