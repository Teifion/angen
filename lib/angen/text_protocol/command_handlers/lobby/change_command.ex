defmodule Angen.TextProtocol.Lobby.ChangeCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/change"

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

  def handle(changes, state) do
    IO.puts "#{__MODULE__}:#{__ENV__.line}"
    IO.inspect changes
    IO.puts ""

    Teiserver.Api.update_lobby(state.lobby_id, changes)
    SuccessResponse.generate(name(), state)
  end
end
