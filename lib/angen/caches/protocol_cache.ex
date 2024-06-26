defmodule Teiserver.Caches.ProtocolCache do
  @moduledoc """
  Caches for the json schemas used in the protocol.
  """

  use Supervisor
  import Teiserver.Helpers.CacheHelper, only: [add_cache: 1]

  def start_link(opts) do
    with {:ok, sup} <- Supervisor.start_link(__MODULE__, :ok, opts),
         :ok <- Angen.Helpers.JsonSchemaHelper.load(),
         :ok <- Angen.TextProtocol.ExternalDispatch.cache_dispatches() do
      {:ok, sup}
    end
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:protocol_schemas),
      add_cache(:protocol_command_dispatches)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
