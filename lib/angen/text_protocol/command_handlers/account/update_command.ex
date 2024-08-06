defmodule Angen.TextProtocol.Account.UpdateCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "account/update"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(attrs, state) do
    user = Teiserver.get_user_by_id(state.user_id)

    case Teiserver.Account.update_limited_user(user, attrs) do
      {:ok, _user} ->
        SuccessResponse.generate(name(), state)

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map_join(", ", fn {key, {message, _}} ->
            "#{key}: #{message}"
          end)

        FailureResponse.generate(
          {name(), "There was an error changing your details: #{errors}"},
          state
        )
    end
  end
end
