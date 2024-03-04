defmodule Angen.TextProtocol.UserInfoResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "whois"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(user, state) do
    json_user = TypeConvertors.convert(user)

    result = %{
      "command" => "whois",
      "result" => "success",
      "user" => json_user
    }

    {result, state}
  end
end
