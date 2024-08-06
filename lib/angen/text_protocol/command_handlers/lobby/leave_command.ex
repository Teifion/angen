defmodule Angen.TextProtocol.Lobby.LeaveCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/leave"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(_, %{lobby_id: nil} = state) do
    FailureResponse.generate({name(), "Not in a lobby"}, state)
  end

  def handle(_, state) do
    Teiserver.remove_client_from_lobby(state.user_id, state.lobby_id)
    SuccessResponse.generate(name(), state)
  end
end
