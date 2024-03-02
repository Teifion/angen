defmodule Angen.TextProtocol.CommandHandlers.Register do
  @moduledoc """
  {"command":"register","name":"teifion","password":"password1","email":"teifion@teifion"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec command :: String.t()
  def command, do: "register"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => name, "password" => password, "email" => email}, state) do
    params = %{
      "name" => name,
      "password" => password,
      "email" => email
    }

    case Teiserver.Account.create_user(params) do
      {:ok, user} ->
        TextProtocol.RegisterResponse.generate(:success, user, state)

      {:error, changeset} ->
        TextProtocol.RegisterResponse.generate(:error, changeset, state)
    end
  end
end
