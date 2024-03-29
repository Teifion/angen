defmodule Angen.TextProtocol.InternalDispatch do
  @moduledoc """

  """
  alias Angen.TextProtocol.InfoHandlers
  alias Angen.TextProtocol.ErrorResponse

  @spec handle(map, Angen.ConnState.t()) ::
          {nil | Angen.raw_message() | [Angen.raw_message()], Angen.ConnState.t()}
  def handle(message, state) do
    try do
      do_dispatch(message, state)
    rescue
      e in FunctionClauseError ->
        handle_error(e, __STACKTRACE__, state)
        send(self(), :disconnect_on_error)

        ErrorResponse.generate(
          "Server FunctionClauseError for message #{inspect(message)}",
          state
        )

      e ->
        handle_error(e, __STACKTRACE__, state)
        send(self(), :disconnect_on_error)

        ErrorResponse.generate(
          "Internal server error for message #{inspect(message)}",
          state
        )
    end
  end

  defp do_dispatch(message, state) do
    module = lookup(message.topic, message.event)
    module.handle(message, state)
  end

  @spec lookup(String.t(), atom()) :: module()
  # User
  def lookup("Teiserver.Communication.User:" <> _, :message_received), do: InfoHandlers.Messaged
  def lookup("Teiserver.Communication.User:" <> _, :message_sent), do: InfoHandlers.Noop
  def lookup("Teiserver.Communication.User:" <> _, _), do: InfoHandlers.NoopLog

  # Client
  def lookup("Teiserver.Connections.Client:" <> _, :client_updated),
    do: InfoHandlers.ClientUpdated

  def lookup("Teiserver.Connections.Client:" <> _, :joined_lobby),
    do: InfoHandlers.ClientJoinedLobby

  def lookup("Teiserver.Connections.Client:" <> _, :left_lobby),
    do: InfoHandlers.ClientLeftLobby

  def lookup("Teiserver.Connections.Client:" <> _, :client_destroyed),
    do: InfoHandlers.ClientDestroyed

  # Lobby
  def lookup("Teiserver.Game.Lobby:" <> _, :lobby_updated), do: InfoHandlers.LobbyUpdated
  def lookup("Teiserver.Game.Lobby:" <> _, :lobby_user_joined), do: InfoHandlers.UserJoinedLobby
  def lookup("Teiserver.Game.Lobby:" <> _, :lobby_user_left), do: InfoHandlers.UserLeftLobby
  def lookup("Teiserver.Game.Lobby:" <> _, :lobby_closed), do: InfoHandlers.LobbyClosed
  def lookup("Teiserver.Game.Lobby:" <> _, :lobby_client_change), do: InfoHandlers.ClientUpdated
  def lookup("Teiserver.Game.Lobby:" <> _, :message_received), do: InfoHandlers.LobbyMessageReceived

  # Fallback
  def lookup(topic, event), do: raise("No module for info topic:`#{topic}`, event:`#{event}`")

  defp handle_error(error, stacktrace, _state) do
    # This will generate the error and raise it in all the normal ways
    # but will not break this process thus not breaking the user connection
    spawn(fn ->
      reraise error, stacktrace
    end)

    # Comment out the above and uncomment the below to break the
    # connection on error

    # reraise error, stacktrace
  end
end
