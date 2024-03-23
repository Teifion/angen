defmodule Angen.TextProtocol.System.IntegrationDataResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/integration_data"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate(_, state) do
    bots = Teiserver.Account.list_users(where: [
      has_group: "integration"
    ], limit: :infinity)

    result = %{
      "bots" => TypeConvertors.convert(bots)
    }

    {result, state}
  end
end
