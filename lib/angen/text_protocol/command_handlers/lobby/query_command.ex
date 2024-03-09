defmodule Angen.TextProtocol.Lobby.QueryCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "lobby/query"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"filters" => filters}, state) do
    IO.puts("#{__MODULE__}:#{__ENV__.line}")
    IO.inspect(filters)
    IO.puts("")

    lobbies = Teiserver.Api.list_lobby_summaries()
    TextProtocol.Lobby.ListResponse.generate(lobbies, state)
  end
end
