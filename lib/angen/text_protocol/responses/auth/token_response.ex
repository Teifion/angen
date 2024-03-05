defmodule Angen.TextProtocol.Auth.TokenResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "auth/token"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(token, state) do
    result = %{
      "token" => TypeConvertors.convert(token)
    }

    {result, state}
  end
end
