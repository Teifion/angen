defmodule Angen.TextProtocol.Lobby.MatchEndCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  # Currently adding the match start and match end commands, need to write tests for the commands added and give them json objects

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/match_end"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(_, %{lobby_id: nil} = state) do
    FailureResponse.generate({name(), "Must be in a lobby"}, state)
  end

  def handle(_, %{lobby_host?: false} = state) do
    FailureResponse.generate({name(), "Must be a lobby host"}, state)
  end

  def handle(outcome, state) do
    client = Teiserver.get_client(state.user_id)
    lobby = Teiserver.get_lobby(state.lobby_id)

    cond do
      client.lobby_id == nil ->
        FailureResponse.generate({name(), "Not in a lobby"}, state)

      client.lobby_host? == false ->
        FailureResponse.generate({name(), "Not a lobby host"}, state)

      lobby.match_ongoing? == false ->
        FailureResponse.generate({name(), "Match is not currently ongoing"}, state)

      true ->
        Teiserver.end_match(lobby.match_id, outcome)
        SuccessResponse.generate(name(), state)
    end
  end
end
