defmodule Angen.TextProtocol.System.IntegrationDataCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec name :: String.t()
  def name, do: "system/integration_data"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(%{}, state) do
    if Angen.DevSupport.integration_active?() do
      TextProtocol.System.IntegrationDataResponse.generate(:ok, state)
    else
      FailureResponse.generate({name(), "Integration not active"}, state)
    end
  end
end
