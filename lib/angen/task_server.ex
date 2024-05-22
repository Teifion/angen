defmodule Angen.TaskServer do
  @moduledoc """
  A GenServer for handling tasks we want to be replicated across all connected nodes.
  """

  use GenServer
  alias Phoenix.PubSub
  require Logger

  @impl true
  def handle_info(%{task: "PersistServerMinuteTask"} = msg, state) do
    Angen.Logging.PersistServerMinuteTask.perform(Map.get(msg, :opts, %{}))

    {:noreply, state}
  end

  def handle_info(%{task: task}, state) do
    Logger.error("Angen.TaskServer: No handler for task of #{task}")
    {:noreply, state}
  end

  # Startup
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:opts], opts)
  end

  @impl true
  def init(_opts) do
    PubSub.subscribe(Angen.PubSub, "angen_tasks")

    {:ok, %{}}
  end
end
