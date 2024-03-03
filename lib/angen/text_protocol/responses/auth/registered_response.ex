defmodule Angen.TextProtocol.RegisteredResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "registered"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(%Teiserver.Account.User{} = user, state) do
    result = %{
      "user" => TypeConvertors.convert(user)
    }

    {result, state}
  end
end
