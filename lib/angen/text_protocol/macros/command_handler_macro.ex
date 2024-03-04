defmodule Angen.TextProtocol.CommandHandlerMacro do
  @moduledoc """
  Apply to handlers with `use Angen.TextProtocol.CommandHandlerMacro
  """

  @callback name :: String.t()

  @callback handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()

  defmacro __using__(_opts) do
    quote do
      @behaviour Angen.TextProtocol.CommandHandlerMacro

      alias Angen.TextProtocol
      alias Angen.TextProtocol.{FailureResponse, SuccessResponse}
      alias Teiserver.Api
    end
  end
end
