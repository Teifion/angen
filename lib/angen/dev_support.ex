defmodule Angen.DevSupport do
  # alias Angen.DevSupport.BotLib

  @spec integration_active?() :: boolean
  defdelegate integration_active?, to: Angen.DevSupport.ManagerServer
end
