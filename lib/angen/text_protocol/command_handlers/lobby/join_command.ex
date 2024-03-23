defmodule Angen.TextProtocol.Lobby.JoinCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro
  alias Angen.TextProtocol.Lobby.JoinedResponse

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/join"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"id" => lobby_id} = msg, state) do
    case Api.can_add_client_to_lobby(state.user_id, lobby_id, msg["password"]) do
      {true, _} ->
        case Api.add_client_to_lobby(state.user_id, lobby_id) do
          {:ok, shared_secret, lobby} ->
            JoinedResponse.generate({shared_secret, lobby}, state)

          {:error, reason} ->
            FailureResponse.generate({name(), reason}, state)
        end

      {false, reason} ->
        FailureResponse.generate({name(), reason}, state)
    end
  end
end
