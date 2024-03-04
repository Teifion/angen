defmodule Angen.TextProtocol.ExternalDispatch do
  @moduledoc """

  """
  alias Angen.TextProtocol.ErrorResponse
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
    module = get_dispatch_module(message["name"])
    {response, state} = module.handle(message["command"], state)

    if message["message_id"] do
      {Map.put(response, "message_id", message["message_id"]), state}
    else
      {response, state}
    end
  end

  @spec get_dispatch_module(String.t()) :: module()
  def get_dispatch_module(command) do
    case Cachex.get!(:protocol_command_dispatches, command) do
      nil ->
        raise("No module for command #{command}")

      m ->
        m
    end
  end

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
            IO.puts ""
            IO.inspect response
            IO.puts ""

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

  @spec cache_dispatches() :: :ok
  def cache_dispatches() do
    {:ok, module_list} = :application.get_key(:angen, :modules)

    # First, build the lookup from modules implementing this behaviour
    # and exporting a name/0 function
    lookup =
      module_list
      |> Enum.filter(fn m ->
        Code.ensure_loaded(m)
        case m.__info__(:attributes)[:behaviour] do
          [] -> false
          nil -> false
          b -> Enum.member?(b, Angen.TextProtocol.CommandHandlerMacro)
        end
      end)
      |> Enum.filter(fn m ->
        function_exported?(m, :name, 0)
      end)
      |> Map.new(fn m ->
        {m.name(), m}
      end)

    old = Cachex.get!(:protocol_command_dispatches, "all") || []

    # Store all keys, we'll use it later for removing old ones
    Cachex.put(:protocol_command_dispatches, "all", Map.keys(lookup))

    # Now store our lookups
    lookup
    |> Enum.each(fn {key, func} ->
      Cachex.put(:protocol_command_dispatches, key, func)
    end)

    # Delete out-dated keys
    old
    |> Enum.reject(fn old_key ->
      Map.has_key?(lookup, old_key)
    end)
    |> Enum.each(fn old_key ->
      Cachex.del(:protocol_command_dispatches, old_key)
    end)

    :ok
  end
end
