defmodule Teiserver.Caches.MetadataCache do
  @moduledoc """
  Cache for global runtime variables
  """

  use Supervisor
  import Teiserver.Helpers.CacheHelper, only: [add_cache: 1]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:angen_metadata)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
