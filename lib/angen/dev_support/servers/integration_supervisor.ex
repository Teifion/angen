defmodule Angen.DevSupport.IntegrationSupervisor do
  @moduledoc """
  The dynamic supervisor for the Integration services
  """
  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 10_000,
      max_seconds: 1
    )
  end

  @spec start_integration_supervisor_children() ::
          :ok | {:error, :start_failure}
  def start_integration_supervisor_children() do
    if Angen.DevSupport.ManagerServer.integration_active?() do
      start_integration()
    else
      :integration_inactive
    end
  end

  @spec start_integration() :: :ok | {:error, :start_failure}
  defp start_integration() do
    case DynamicSupervisor.start_child(
           __MODULE__,
           {Angen.DevSupport.ManagerServer, []}
         ) do
      {:ok, _pid} ->
        :ok

      {:ok, _pid, _info} ->
        :ok

      {:error, {:already_started, _pid}} ->
        :ok

      error ->
        Logger.error("Failed to start Manager Server, error:#{inspect(error)}.")
        {:error, :start_failure}
    end
  end
end
