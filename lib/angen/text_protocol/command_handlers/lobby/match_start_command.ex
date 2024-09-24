defmodule Angen.TextProtocol.Lobby.MatchStartCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/match_start"

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

  def handle(_, state) do
    client = Teiserver.get_client(state.user_id)
    lobby = Teiserver.get_lobby(state.lobby_id)

    # We repeat the cases here because it's possible the connection
    # state isn't completely up to date
    cond do
      client.lobby_id == nil ->
        FailureResponse.generate({name(), "Not in a lobby"}, state)

      client.lobby_host? == false ->
        FailureResponse.generate({name(), "Not a lobby host"}, state)

      lobby.match_ongoing? ->
        FailureResponse.generate({name(), "Match has already started"}, state)

      true ->
        case Teiserver.start_match(lobby.id) do
          {:ok, _match} ->
            SuccessResponse.generate(name(), state)

          {:error, error_atom} ->
            FailureResponse.generate({name(), to_string(error_atom)}, state)
        end
    end
  end
end
