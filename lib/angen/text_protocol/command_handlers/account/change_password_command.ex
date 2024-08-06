defmodule Angen.TextProtocol.Account.ChangePasswordCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro
  alias Angen.Account.UserTokenLib

  @impl true
  @spec name :: String.t()
  def name, do: "account/change_password"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"current_password" => current_password, "new_password" => new_password}, state) do
    user = Teiserver.get_user_by_id(state.user_id)

    params = %{
      "existing" => current_password,
      "password" => new_password,
      "password_confirmation" => new_password
    }

    case Teiserver.Account.update_password(user, params) do
      {:ok, _new_user} ->
        # First, delete the tokens themselves
        UserTokenLib.delete_user_tokens(state.user_id)

        # Now disconnect all connections
        Teiserver.Connections.disconnect_user(state.user_id)

        # Delay a bit just so we don't accidentally send anything
        # in theory what we just did should result in this process dying
        # mid-function call
        :timer.sleep(50)

        # This probably won't make it...
        SuccessResponse.generate(name(), state)

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map_join(", ", fn {key, {message, _}} ->
            "#{key}: #{message}"
          end)

        FailureResponse.generate(
          {name(), "There was an error changing your password: #{errors}"},
          state
        )
    end
  end
end
