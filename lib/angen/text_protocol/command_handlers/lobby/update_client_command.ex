defmodule Angen.TextProtocol.Lobby.UpdateClientCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/update_client"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(_, %{lobby_id: nil} = state) do
    FailureResponse.generate({name(), "Must be in a lobby"}, state)
  end

  @change_keys ~w(
    player?
    player_number
    team_number
    player_colour
  )a

  def handle(changes_raw, state) do
    changes =
      @change_keys
      |> Enum.filter(fn key ->
        Map.has_key?(changes_raw, to_string(key))
      end)
      |> Map.new(fn key ->
        {key, changes_raw[to_string(key)]}
      end)

    if Enum.empty?(changes) do
      FailureResponse.generate({name(), "No changes"}, state)
    else
      Teiserver.update_client_in_lobby(state.user_id, changes, "self_update")
      SuccessResponse.generate(name(), state)
    end
  end
end
