defmodule Angen.TextProtocol.LoginResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "login"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(user, state) do
    result = %{
      "command" => "login",
      "result" => "success",
      "message" => "You are now logged in as '#{user.name}'",
      "user_id" => user.id
    }

    {result, %{state | user_id: user.id}}
  end

  # def do_generate(:failure, reason, state) do
  #   reason_str =
  #     case reason do
  #       :no_user -> "no user"
  #       :bad_password -> "bad password"
  #     end

  #   result = %{
  #     "command" => "login",
  #     "result" => "failure",
  #     "reason" => reason_str
  #   }

  #   {result, state}
  # end
end
