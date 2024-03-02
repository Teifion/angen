defmodule Angen.TextProtocol.RegisterResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(:success, %Teiserver.Account.User{} = user, state) do
    result = %{
      "command" => "register",
      "result" => "success",
      "message" => "User '#{user.name}' created, you can now login with this user"
    }

    {result, state}
  end

  def generate(:failure, changeset, state) do
    IO.puts "Angen.TextProtocol.RegisterResponse"
    IO.inspect changeset
    IO.puts ""

    result = %{
      "command" => "register",
      "result" => "failure",
      "reason" => "There was an error registering"
    }

    {result, state}
  end
end
