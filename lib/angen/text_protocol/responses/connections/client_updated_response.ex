defmodule Angen.TextProtocol.Connections.ClientUpdatedResponse do
  @moduledoc false

  use Angen.TextProtocol.ResponseMacro

  @impl true
  @spec name :: String.t()
  def name, do: "connections/client_updated"

  @impl true
  @spec do_generate(any(), Angen.ConnState.t()) :: Angen.handler_response()
  def do_generate({changes, reason}, state) do
    result = %{
      "changes" => changes,
      "reason" => reason
    }

    {result, state}
  end
end
