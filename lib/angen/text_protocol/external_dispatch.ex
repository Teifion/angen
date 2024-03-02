defmodule Angen.TextProtocol.ExternalDispatch do
  @moduledoc """

  """
  alias Angen.TextProtocol.CommandHandlers
  alias Angen.TextProtocol.ErrorResponse

  @spec handle(Angen.raw_message(), Angen.ConnState.t()) ::
          {nil | Angen.raw_message() | [Angen.raw_message()], Angen.ConnState.t()}
  def handle(message, state) do
    try do
      message
      |> decode_message()
      |> do_dispatch(state)
    rescue
      e in FunctionClauseError ->
        handle_error(e, __STACKTRACE__, state)
        send(self(), :disconnect_on_error)

        ErrorResponse.generate(
          :failure,
          "Server FunctionClauseError for message #{message}",
          state
        )

      e ->
        handle_error(e, __STACKTRACE__, state)
        send(self(), :disconnect_on_error)

        ErrorResponse.generate(:failure, "Internal server error for message #{message}", state)
    end
  end

  defp do_dispatch(message, state) do
    module = lookup(message["command"])
    {response, state} = module.handle(message, state)

    if message["message_id"] do
      {Map.put(response, "message_id", message["message_id"]), state}
    else
      {response, state}
    end
  end

  @spec lookup(String.t()) :: module()
  def lookup("register"), do: CommandHandlers.Register
  def lookup("login"), do: CommandHandlers.Login
  def lookup("clients"), do: CommandHandlers.Clients
  def lookup("whoami"), do: CommandHandlers.Whoami
  def lookup("whois"), do: CommandHandlers.Whois
  def lookup("ping"), do: CommandHandlers.Ping
  def lookup("message"), do: CommandHandlers.Message
  def lookup(cmd), do: raise("No module for command #{cmd}")

  @spec decode_message(Angen.raw_message()) :: Angen.json_message()
  defp decode_message(message) do
    Jason.decode!(message)
  end

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
