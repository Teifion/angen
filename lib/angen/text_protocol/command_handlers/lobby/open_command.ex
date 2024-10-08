defmodule Angen.TextProtocol.Lobby.OpenCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/open"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"name" => name}, state) do
    cond do
      state.lobby_host? == true or state.lobby_id != nil ->
        FailureResponse.generate({name(), "Already in a lobby"}, state)

      true ->
        case Teiserver.open_lobby(state.user_id, name) do
          {:ok, lobby_id} ->
            TextProtocol.Lobby.OpenedResponse.generate(lobby_id, state)

          {:error, :no_name} ->
            FailureResponse.generate({name(), "No name supplied"}, state)
        end
    end
  end
end
