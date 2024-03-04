defmodule Angen.TextProtocol.LoginResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "logged_in"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(user, state) do
    result = %{
      "user" => TypeConvertors.convert(user)
    }

    {result, %{state | user_id: user.id}}
  end
end
