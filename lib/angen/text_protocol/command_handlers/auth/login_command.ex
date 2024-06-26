defmodule Angen.TextProtocol.CommandHandlers.Auth.Login do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "auth/login"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"token" => token_identifier_code, "user_agent" => _} = cmd, state) do
    case Angen.Account.get_user_token_by_identifier(token_identifier_code) do
      nil ->
        FailureResponse.generate({name(), "Bad token"}, state)

      token ->
        bad_ip =
          if Application.get_env(:angen, :require_tokens_to_persist_ip) do
            # If the IP must match, it's a bad ip if they are different
            state.ip != token.ip
          else
            false
          end

        if bad_ip do
          FailureResponse.generate({name(), "Bad token"}, state)
        else
          perform_connection(token, cmd, state)
        end
    end
  end

  defp perform_connection(token, cmd, state) do
    case Teiserver.Api.connect_user(token.user_id, bot?: Map.get(cmd, "bot?", false)) do
      nil ->
        FailureResponse.generate({name(), "No clint created, please retry"}, state)

      _ ->
        TextProtocol.Auth.LoginResponse.generate(token.user_id, state)
    end
  end
end
