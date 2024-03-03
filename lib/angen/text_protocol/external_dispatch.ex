defmodule Angen.TextProtocol.ExternalDispatch do
  @moduledoc """

  """
  alias Angen.TextProtocol.{CommandHandlers, ErrorResponse}
  alias Angen.Helpers.JsonSchemaHelper

  @doc """

  """
  @spec handle(Angen.raw_message(), Angen.ConnState.t()) ::
          {nil | Angen.raw_message() | [Angen.raw_message()], Angen.ConnState.t()}
  def handle(raw_message, state) do
    try do
      with {:ok, decoded_message} <- decode_message(raw_message),
           {:ok, validated_message} <- validate_request(decoded_message),
           {response, new_state} <- do_dispatch(validated_message, state),
           :ok <- validate_response(response)
      do
        {response, new_state}
      else
        # Errors with their request
        {:error, error_message = "Invalid request" <> _} ->
          ErrorResponse.generate(error_message, state)

        {:error, error_message = "Invalid command" <> _} ->
          ErrorResponse.generate(error_message, state)

        # Errors with the response we generated
        {:error, error_message = "Invalid response" <> _} ->
          ErrorResponse.generate(error_message, state)

        {:error, error_message = "Invalid message" <> _} ->
          ErrorResponse.generate(error_message, state)
      end

    rescue
      e in FunctionClauseError ->
        handle_error(e, __STACKTRACE__, state)
        send(self(), :disconnect_on_error)

        ErrorResponse.generate(
          "Server FunctionClauseError for message #{raw_message}",
          state
        )

      e ->
        handle_error(e, __STACKTRACE__, state)
        send(self(), :disconnect_on_error)

        ErrorResponse.generate("Internal server error for message #{raw_message}", state)
    end
  end

  defp do_dispatch(message, state) do
    module = lookup(message["name"])
    {response, state} = module.handle(message["command"], state)

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

  @spec decode_message(Angen.raw_message()) :: {:ok, Angen.json_message()} | {:error, any()}
  defp decode_message(message) do
    Jason.decode(message)
  end

  @spec validate_request(map) :: {:ok, map} | {:error, String.t()}
  defp validate_request(message) do
    command_name = "#{message["name"]}_command.json"

    case JsonSchemaHelper.validate("request.json", message) do
      :ok ->
        case JsonSchemaHelper.validate(command_name, message["command"]) do
          :ok ->
            {:ok, message}

          err ->
            {:error, "Invalid command schema: #{inspect(err)}"}
        end

      err ->
        {:error, "Invalid request schema: #{inspect(err)}"}
    end
  end

  @spec validate_response(map) :: {:ok, map} | {:error, String.t()}
  defp validate_response(response) do
    message_name = "#{response["name"]}_message.json"

    case JsonSchemaHelper.validate("response.json", response) do
      :ok ->
        case JsonSchemaHelper.validate(message_name, response["message"]) do
          :ok ->
            :ok

          err ->
            {:error, "Invalid message schema: #{inspect(err)}"}
        end

      err ->
        {:error, "Invalid response schema: #{inspect(err)}"}
    end
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
