defmodule Angen.TextProtocol.ClientsResponse do
  @moduledoc """

  """

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "clients"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({local_client_ids, global_client_ids}, state) do
    result = %{
      "command" => "clients",
      "result" => "success",
      "local_client_ids" => local_client_ids,
      "global_client_ids" => global_client_ids
    }

    {result, state}
  end
end
