defmodule Angen.TextProtocol.CommandHandlers.Whoami do
  @moduledoc """
  Example usage
  {"command":"whoami"}
  """

  use Angen.TextProtocol.CommandHandlerMacro

  @impl true
  @spec command :: String.t()
  def command, do: "whoami"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    TextProtocol.WhoamiResponse.generate(:not_logged_in, :ok, state)
  end

  def handle(_, state) do
    user = Api.get_user_by_id(state.user_id)
    TextProtocol.WhoamiResponse.generate(:success, user, state)
  end
end
