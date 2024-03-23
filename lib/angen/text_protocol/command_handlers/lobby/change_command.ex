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

  @change_keys ~w(
    host_data
    name
    tags
    settings
    password
    locked?
    public?
    match_type
    rated?
    game_name
    game_version
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

    Teiserver.Api.update_lobby(state.lobby_id, changes)
    SuccessResponse.generate(name(), state)
  end
end
