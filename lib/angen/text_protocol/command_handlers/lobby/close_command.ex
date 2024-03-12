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

  def handle(_, %{lobby_id: nil} = state) do
    FailureResponse.generate({name(), "Must be in a lobby"}, state)
  end

  def handle(_, %{lobby_host?: false} = state) do
    FailureResponse.generate({name(), "Must be a lobby host"}, state)
  end

  def handle(_, state) do
    client = Teiserver.Api.get_client(state.user_id)

    cond do
      client.lobby_id == nil ->
        FailureResponse.generate({name(), "Not in a lobby"}, state)

      client.lobby_host? == false ->
        FailureResponse.generate({name(), "Not a lobby host"}, state)

      true ->
        Teiserver.Api.close_lobby(client.lobby_id)
        SuccessResponse.generate(name(), state)
    end
  end
end
