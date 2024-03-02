defmodule Angen.TextProtocol.InfoHandlers.Noop do
  @moduledoc """
  Used when you don't want to actually do anything with the message
  """
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_message, state) do
    {nil, state}
  end
end
