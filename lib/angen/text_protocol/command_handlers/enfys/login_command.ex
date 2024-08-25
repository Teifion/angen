defmodule Angen.TextProtocol.Enfys.LoginCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "enfys/login"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{"name" => name}, state) do
    user =
      case Teiserver.get_user_by_name(name) do
        nil ->
          {:ok, user} =
            Angen.Account.register_user(%{
              "name" => name,
              "password" => Teiserver.Account.generate_password(),
              "email" => "#{Teiserver.uuid()}@enfys"
            })

          user

        user ->
          user
      end

    case Teiserver.connect_user(user.id) do
      nil ->
        FailureResponse.generate({name(), "No clint created, please retry"}, state)

      _ ->
        TextProtocol.Auth.LoginResponse.generate(user, state)
    end
  end
end
