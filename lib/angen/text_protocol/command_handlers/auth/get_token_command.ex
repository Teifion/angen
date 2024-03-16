defmodule Angen.TextProtocol.CommandHandlers.Auth.GetToken do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "auth/get_token"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => name, "password" => password, "user_agent" => user_agent}, state) do
    case Teiserver.Api.maybe_authenticate_user(name, password) do
      {:ok, user} ->
        case Angen.Account.create_user_token(user.id, "text-protocol", user_agent, state.ip) do
          {:ok, token} ->
            TextProtocol.Auth.TokenResponse.generate(token, state)

          {:error, changeset} ->
            errors =
              changeset.errors
              |> Enum.map_join(", ", fn {key, {message, _}} ->
                "#{key}: #{message}"
              end)

            FailureResponse.generate(
              {name(), "There was an error generating the token: #{errors}"},
              state
            )
        end

      {:error, :no_user} ->
        FailureResponse.generate({name(), "Bad authentication"}, state)

      {:error, :bad_password} ->
        FailureResponse.generate({name(), "Bad authentication"}, state)
    end
  end
end
