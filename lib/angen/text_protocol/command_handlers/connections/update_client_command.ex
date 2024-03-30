defmodule Angen.TextProtocol.Connections.UpdateClientCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connections/update_client"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  @change_keys ~w(
    afk?
    in_game?
    ready?
    sync
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
      Teiserver.Api.update_client_full(state.user_id, changes, "self_update")
      SuccessResponse.generate(name(), state)
    end
  end
end
