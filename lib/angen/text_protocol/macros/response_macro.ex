defmodule Angen.TextProtocol.ResponseMacro do
  @moduledoc """
  Apply to handlers with `use Angen.TextProtocol.ResponseMacro`
  """
  @callback name() :: String.t()

  @callback do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()

  defmacro __using__(_opts) do
    quote do
      @behaviour Angen.TextProtocol.ResponseMacro

      alias Angen.TextProtocol.TypeConvertors

      @spec generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
      def generate(data, state) do
        {result, new_state} = do_generate(data, state)

        {%{"name" => name(), "message" => result}, new_state}
      end
    end
  end
end
