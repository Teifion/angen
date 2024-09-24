defmodule Angen.DevSupport.LobbyHostPlayBot do
  @moduledoc """
  Creates an account called `LobbyHostPlayBot` which will host a lobby.
  """
  use Angen.DevSupport.BotMacro
  require Logger

  @interval 5_000

  def handle_info(:startup, state) do
    name =
      if state.params[:behaviour] do
        "LobbyHostPlayBot#{state.params[:behaviour]}"
      else
        "LobbyHostPlayBot"
      end

    user = BotLib.get_or_create_bot_account(name)
    client = Teiserver.connect_user(user.id)

    if client do
      send(self(), :tick)
      :timer.send_interval(@interval, :tick)
      {:noreply, %{state | user: user, connected: true, lobby_id: nil}}
    else
      :timer.send_after(500, :startup)
      {:noreply, state}
    end
  end

  def handle_info(:tick, %{lobby_id: nil} = state) do
    lobby_id =
      case Teiserver.open_lobby(state.user.id, "Integration test lobby (play)") do
        {:ok, lobby_id} ->
          Logger.error("Play lobby opened - #{lobby_id}")
          lobby_id

        {:error, :already_in_lobby} ->
          client = Teiserver.get_client(state.user.id)
          client.lobby_id

        {:error, _} ->
          nil
      end

    {:noreply, %{state | lobby_id: lobby_id}}
  end

  def handle_info(:tick, state) do
    client = Teiserver.get_client(state.user.id)
    lobby = Teiserver.get_lobby(state.lobby_id)

    state =
      cond do
        client.in_game? == false and Enum.count(lobby.players) > 1 ->
          # We have the players, lets go
          start_game(state)

        client.in_game? ->
          # We are in game
          state

        true ->
          # Waiting for more players
          state
      end

    {:noreply, state}
  end

  def handle_info(%{event: :client_updated, topic: "Teiserver.Connections.Client:" <> _}, state) do
    {:noreply, state}
  end

  def handle_info(
        %{event: :joined_lobby, topic: "Teiserver.Connections.Client:" <> _, lobby_id: lobby_id},
        state
      ) do
    {:noreply, %{state | lobby_id: lobby_id}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  defp start_game(state) do
    state
  end

  # defp end_game(state) do
  #   state
  # end
end
