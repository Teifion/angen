defmodule Angen.TextProtocol.ClientsResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @spec generate(atom, any(), Angen.ConnState.t()) :: Angen.handler_response()
  def generate(_, {local_client_ids, global_client_ids}, state) do
    result = %{
      "command" => "clients",
      "result" => "success",
      "local_client_ids" => local_client_ids,
      "global_client_ids" => global_client_ids
    }

    {result, state}
  end
end
