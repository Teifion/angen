defmodule Angen.TextProtocol.WhoamiResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "whoami"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(_, state) do
    result = %{
      "command" => "whoami",
      "result" => "failure",
      "message" => "You are not logged in"
    }

    {result, state}
  end

  # def do_generate(user, state) do
  #   json_user = TypeConvertors.convert(user)

  #   result = %{
  #     "command" => "whoami",
  #     "result" => "success",
  #     "user" => json_user
  #   }

  #   {result, state}
  # end
end
