defmodule Angen.TextProtocol.CommandHandlers.Register do
  @moduledoc """
  {"command":"register","name":"teifion","password":"password1","email":"teifion@teifion"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "register"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => username, "password" => password, "email" => email}, state) do
    params = %{
      "name" => username,
      "password" => password,
      "email" => email
    }

    case Teiserver.Account.create_user(params) do
      {:ok, user} ->
        TextProtocol.RegisteredResponse.generate(user, state)

      {:error, changeset} ->
        IO.puts ""
        IO.inspect changeset
        IO.puts ""

        FailureResponse.generate({name(), "There was an error registering"}, state)
    end
  end
end
