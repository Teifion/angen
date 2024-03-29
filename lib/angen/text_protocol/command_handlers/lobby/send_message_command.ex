defmodule Angen.TextProtocol.Lobby.SendMessageCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/send_message"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(_, %{lobby_id: nil} = state) do
    FailureResponse.generate({name(), "Not in a lobby"}, state)
  end

  def handle(%{"content" => content}, state) do
    case Api.send_lobby_message(state.user_id, state.lobby_id, content) do
      {:ok, _match_message} ->
        SuccessResponse.generate(name(), state)

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map_join(", ", fn {key, {message, _}} ->
            "#{key}: #{message}"
          end)

        FailureResponse.generate(
          {name(), "There was an error changing your details: #{errors}"},
          state
        )
    end
  end
end
