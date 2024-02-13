defmodule Angen.TextProtocol.WhoamiResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(:not_logged_in, _, state) do
    result = %{
      "command" => "whoami",
      "result" => "failure",
      "message" => "You are not logged in"
    }

    {result, state}
  end

  def generate(:success, user, state) do
    json_user = TypeConvertors.convert(user)

    result = %{
      "command" => "whoami",
      "result" => "success",
      "user" => json_user
    }

    {result, state}
  end
end
