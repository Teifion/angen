defmodule Angen.TextProtocol.MessageResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "message"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({:no_user_found, to_name}, state) do
    result = %{
      "command" => "message",
      "result" => "failure",
      "reason" => "no user found by name '#{to_name}'"
    }

    {result, state}
  end

  # def do_generate(_msg, state) do
  #   result = %{
  #     "command" => "message",
  #     "result" => "success"
  #   }

  #   {result, state}
  # end
end
