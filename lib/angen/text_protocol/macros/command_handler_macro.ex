defmodule Angen.TextProtocol.CommandHandlerMacro do
  @moduledoc """
  Apply to handlers with `use Angen.TextProtocol.CommandHandlerMacro`

  Template:
  defmodule Angen.TextProtocol.CommandHandlers.Login do
    Example usage
    {"command": ""}

    use Angen.TextProtocol.CommandHandlerMacro

    @impl true
    @spec command :: String.t()
    def command, do: nil

    @impl true
    @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
    def handle(msg, state) do
      # Do stuff here
      TextProtocol.MODULEResponse.generate(:success, data, state)
    end
  end

  """

  @callback command() :: String.t()

  @callback handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()

  defmacro __using__(_opts) do
    quote do
      @behaviour Angen.TextProtocol.CommandHandlerMacro

      alias Angen.TextProtocol
      alias Teiserver.Api
    end
  end
end
