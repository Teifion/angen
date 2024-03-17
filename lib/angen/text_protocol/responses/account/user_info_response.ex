defmodule Angen.TextProtocol.Account.UserInfoResponse do
  @moduledoc false
  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "account/user_info"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(users, state) do
    result = %{
      "users" => TypeConvertors.convert(users)
    }

    {result, state}
  end
end
