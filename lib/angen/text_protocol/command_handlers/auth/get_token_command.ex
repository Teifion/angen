defmodule Angen.TextProtocol.CommandHandlers.Auth.GetToken do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "auth/get_token"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"email" => email, "password" => password, "user_agent" => user_agent}, state) do
    case Teiserver.maybe_authenticate_user_by_email(email, password) do
      {:ok, user} ->
        do_handle(user, user_agent, state)

      {:error, :no_user} ->
        Teiserver.create_anonymous_audit_log(state.ip, "auth/get_token", %{
          reason: "no_user",
          email: email,
          user_agent: user_agent
        })

        FailureResponse.generate({name(), "Bad authentication"}, state)

      {:error, _} ->
        FailureResponse.generate({name(), "Bad authentication"}, state)
    end
  end

  def handle(%{"id" => id, "password" => password, "user_agent" => user_agent}, state) do
    case Teiserver.maybe_authenticate_user_by_id(id, password) do
      {:ok, user} ->
        do_handle(user, user_agent, state)

      {:error, :no_user} ->
        Teiserver.create_anonymous_audit_log(state.ip, "auth/get_token", %{
          reason: "no_user",
          id: id,
          user_agent: user_agent
        })

        FailureResponse.generate({name(), "Bad authentication"}, state)

      {:error, _} ->
        FailureResponse.generate({name(), "Bad authentication"}, state)
    end
  end

  defp do_handle(user, user_agent, state) do
    if Angen.Account.allow_login?(user) do
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
    else
      FailureResponse.generate({name(), "Unable to generate token"}, state)
    end
  end
end
