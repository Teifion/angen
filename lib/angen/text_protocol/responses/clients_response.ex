defmodule Angen.TextProtocol.ClientsResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(_, client_ids, state) do
    result = %{
      "command" => "clients",
      "result" => "success",
      "client_ids" => client_ids
    }

    {result, state}
  end
end
