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
        #  =

        :telemetry.execute(
          [:angen, :proto, :response],
          %{name: name()},
          %{}
        )

        {result, new_state} = :telemetry.span(
          [:angen, :protocol, :response],
          %{name: name()},
          fn ->
            r = do_generate(data, state)
            {r, %{metadata: "Information"}}
          end
        )

        {%{"name" => name(), "message" => result}, new_state}
      end
    end
  end
end
