defmodule Angen.TextProtocol.Lobby.JoinCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/join"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{}, state) do
    case true do
      {:ok, result} ->
        Teiserver.Api.do_something()
        TextProtocol.Lobby.JoinResponse.generate(result, state)
        SuccessResponse.generate(name(), state)

      {:error, reason} ->
        FailureResponse.generate({name(), reason}, state)
    end
  end
end
