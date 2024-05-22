defmodule Angen.Logging.TriggerPersistServerMinuteTask do
  @moduledoc false
  use Oban.Worker, queue: :logging

  alias Phoenix.PubSub

  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(_) do
    if Angen.startup_complete?() do
      PubSub.broadcast(Angen.PubSub, "angen_tasks", %{
        task: "PersistServerMinuteTask"
      })

      :timer.sleep(5_000)

      %{}
      |> Angen.Logging.CombineServerMinuteTask.new()
      |> Oban.insert()
    end

    :ok
  end
end
