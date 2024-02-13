defmodule Angen.TextProtocol.WhoisResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(:no_user_name, name, state) do
    result = %{
      "command" => "whois",
      "result" => "failure",
      "message" => "No user found the name '#{name}'"
    }

    {result, state}
  end

  def generate(:no_user_id, id, state) do
    result = %{
      "command" => "whois",
      "result" => "failure",
      "message" => "No user found by the id '#{id}'"
    }

    {result, state}
  end

  def generate(:success, user, state) do
    json_user = TypeConvertors.convert(user)

    result = %{
      "command" => "whois",
      "result" => "success",
      "user" => json_user
    }

    {result, state}
  end
end
