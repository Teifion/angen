defmodule Angen.TextProtocol.MessageResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(:success | :failure, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(:failure, {:no_user_found, to_name}, state) do
    result = %{
      "command" => "message",
      "result" => "failure",
      "reason" => "no user found by name '#{to_name}'"
    }

    {result, state}
  end

  def generate(:success, _msg, state) do
    result = %{
      "command" => "message",
      "result" => "success"
    }

    {result, state}
  end
end
