defmodule Angen.TextProtocol.LoginResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(:success, user, state) do
    result = %{
      "command" => "login",
      "result" => "success",
      "message" => "You are now logged in as '#{user.name}'"
    }

    {result, %{state | user_id: user.id}}
  end

  def generate(:failure, reason, state) do
    reason_str = case reason do
      :no_user -> "no user"
      :bad_password -> "bad password"
    end

    result = %{
      "command" => "login",
      "result" => "failure",
      "reason" => reason_str,
    }

    {result, state}
  end
end
