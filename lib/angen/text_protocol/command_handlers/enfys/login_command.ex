defmodule Angen.TextProtocol.Enfys.LoginCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "enfys/login"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => name}, state) do
    user = case Api.get_user_by_name(name) do
      nil ->
        {:ok, user} = Teiserver.Account.register_user(%{
          "name" => name,
          "password" => Teiserver.Account.generate_password(),
          "email" => "#{Teiserver.uuid()}@enfys"
        })
        user
      user ->
        user
    end

    Teiserver.Api.connect_user(user.id)
    TextProtocol.Auth.LoginResponse.generate(user, state)
  end
end
