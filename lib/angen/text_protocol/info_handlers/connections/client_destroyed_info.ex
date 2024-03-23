defmodule Angen.TextProtocol.InfoHandlers.ClientDestroyed do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(msg, state) do
    if msg.user_id == state.user_id do
      send(self(), :disconnect)
    end

    nil_response(state)
  end
end
