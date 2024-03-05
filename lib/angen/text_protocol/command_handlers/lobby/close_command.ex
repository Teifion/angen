defmodule Angen.TextProtocol.Lobby.CloseCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/close"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(_, state) do
    case Teiserver.Api.get_client(state.user_id) do
      %{lobby_host?: true, lobby_id: lobby_id} ->
        if lobby_id do
          Teiserver.Api.close_lobby(lobby_id)
          SuccessResponse.generate(name(), state)
        else
          FailureResponse.generate({name(), "Not in a lobby"}, state)
        end

      _ ->
        FailureResponse.generate({name(), "Not a lobby host"}, state)
    end
  end
end
