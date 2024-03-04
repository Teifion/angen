defmodule Angen.TextProtocol.Account.UserInfoResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "account/user_info"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(user, state) do
    result = %{
      "user" => TypeConvertors.convert(user)
    }

    {result, state}
  end
end
