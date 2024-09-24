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
    with true <- Teiserver.can_add_client_to_lobby(state.user_id, lobby_id, msg["password"]),
         {:ok, shared_secret, lobby} <- Teiserver.add_client_to_lobby(state.user_id, lobby_id) do
      JoinedResponse.generate({shared_secret, lobby}, state)
    else
      {false, :no_lobby} ->
        FailureResponse.generate({name(), "No lobby"}, state)

      {false, :existing_member} ->
        FailureResponse.generate({name(), "Already an existing member"}, state)

      {false, :client_disconnected} ->
        FailureResponse.generate({name(), "Client is disconnected"}, state)

      {false, :already_in_a_lobby} ->
        FailureResponse.generate({name(), "Already in a lobby"}, state)

      {false, :incorrect_password} ->
        FailureResponse.generate({name(), "Incorrect password"}, state)

      {false, :lobby_is_locked} ->
        FailureResponse.generate({name(), "Lobby is locked"}, state)
    end
  end
end
