defmodule Angen.TextProtocol.CommandHandlers.Login do
  @moduledoc """
  Bad login
  {"command":"login","name":"teifion","password":"badpass"}

  Good login
  {"command":"login","name":"teifion","password":"password1"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "login"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => name, "password" => password}, state) do
    case Teiserver.Api.maybe_authenticate_user(name, password) do
      {:ok, user} ->
        Teiserver.Api.connect_user(user.id)
        TextProtocol.LoginResponse.generate(user, state)

      {:error, :no_user} ->
        FailureResponse.generate({name(), "No user"}, state)

      {:error, :bad_password} ->
        FailureResponse.generate({name(), "No user"}, state)
    end
  end
end
