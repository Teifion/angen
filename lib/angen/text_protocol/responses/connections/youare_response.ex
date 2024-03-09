defmodule Angen.TextProtocol.Connections.YouareResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connections/youare"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(user, state) do
    result = %{
      "user" => TypeConvertors.convert(user)
    }

    {result, state}
  end
end
