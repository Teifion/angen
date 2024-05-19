defmodule Angen.TextProtocol.InfoHandlers.ClientConnected do
  @moduledoc false
  use Angen.TextProtocol.InfoMacro

  @impl true
  @spec handle(map, Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_msg, state) do
    # TODO: Work out what to do here, do we even need to do anything?
    # if msg.user_id == state.user_id do
    #   :ok
    # end

    nil_response(state)
  end
end
