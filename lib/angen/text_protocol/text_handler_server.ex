defmodule Angen.TextProtocol.TextHandlerServer do
  @moduledoc """
  This is the server managing the user connection.
  """
  use ThousandIsland.Handler

  alias Angen.TextProtocol.{ExternalDispatch, InternalDispatch}

  @impl ThousandIsland.Handler
  def handle_connection(socket, _state) do
    ip =
      Map.get(socket.span.start_metadata, :remote_address)
      |> Tuple.to_list()
      |> Enum.join(".")

    {:continue,
     %{
       # Connection info
       ip: ip,
       socket: socket,

       # Client/User info
       user_id: nil,
       user: nil,
       lobby_host?: false,
       party_id: nil,
       lobby_id: nil,
       in_game?: false
     }}
  end

  @impl ThousandIsland.Handler
  # If Ctrl + C is sent through it kills the connection, makes telnet debugging easier
  def handle_data(<<255, 244, 255, 253, 6>>, _socket, state), do: {:close, state}

  # Empty message, we can ignore this
  def handle_data("\n", _socket, state), do: {:continue, state}
  def handle_data("\r\n", _socket, state), do: {:continue, state}

  # Main user input handler
  def handle_data(data, socket, state) do
    clean_data = String.trim(data)

    # This part handles the actual command
    {response, new_state} = ExternalDispatch.handle(clean_data, state)

    # If we get one or more responses, we send them
    response
    |> List.wrap()
    |> Enum.reject(&(&1 == nil))
    |> Enum.each(fn r ->
      msg = encode_message(r)
      ThousandIsland.Socket.send(socket, "#{msg}\n")
    end)

    {:continue, new_state}
  end

  defp encode_message(message) do
    # Might want to use javascript_safe: true as an opt
    Jason.encode!(message)
  end

  # We have disconnect on error so we can later more easily make it so people can stay connected on error if needed for some reason
  def handle_info(:disconnect_on_error, state) do
    # terminate(:disconnect_on_error, state)
    {:noreply, state}
  end

  def handle_info(:disconnect, state) do
    terminate(:disconnect, state)
    {:noreply, state}
  end

  def handle_info(%{} = message, {_socket, state}) do
    # # Sometimes we'll get this as {socket, state} and sometimes just state
    # # this prevents errors around that
    # state = case state do
    #   {_socket, state} -> state
    #   state -> state
    # end

    # This handles the actual message
    {response, new_state} = InternalDispatch.handle(message, state)

    # If we get one or more responses, we send them
    (response || [])
    |> List.wrap()
    |> Enum.each(fn r ->
      msg = encode_message(r)
      ThousandIsland.Socket.send(state.socket, "#{msg}\n")
    end)

    {:noreply, {new_state.socket, new_state}}
  end
end
