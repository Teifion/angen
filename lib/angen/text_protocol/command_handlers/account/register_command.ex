defmodule Angen.TextProtocol.CommandHandlers.Account.Register do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "account/register"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => username, "password" => password, "email" => email}, state) do
    params = %{
      "name" => username,
      "password" => password,
      "email" => email
    }

    case Angen.Account.register_user(params) do
      {:ok, user} ->
        TextProtocol.Account.RegisteredResponse.generate(user, state)

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map_join(", ", fn {key, {message, _}} ->
            "#{key}: #{message}"
          end)

        FailureResponse.generate({name(), "There was an error registering: #{errors}"}, state)
    end
  end
end
