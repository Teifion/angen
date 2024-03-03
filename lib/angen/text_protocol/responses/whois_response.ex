defmodule Angen.TextProtocol.WhoisResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "whois"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(name, state) do
    result = %{
      "command" => "whois",
      "result" => "failure",
      "message" => "No user found the name '#{name}'"
    }

    {result, state}
  end

  # def do_generate(:no_user_id, id, state) do
  #   result = %{
  #     "command" => "whois",
  #     "result" => "failure",
  #     "message" => "No user found by the id '#{id}'"
  #   }

  #   {result, state}
  # end

  # def do_generate(user, state) do
  #   json_user = TypeConvertors.convert(user)

  #   result = %{
  #     "command" => "whois",
  #     "result" => "success",
  #     "user" => json_user
  #   }

  #   {result, state}
  # end
end
