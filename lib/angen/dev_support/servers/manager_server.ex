defmodule Angen.DevSupport.ManagerServer do
  @moduledoc """
  The genserver managing all other DevSupport servers
  """
  use GenServer
  require Logger

  @startup_delay 500

  def start_link(params, _opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      params,
      name: __MODULE__
    )
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), {:startup, 1}, @startup_delay)

    {:ok, :initial_state}
  end

  @impl true
  def handle_call(other, from, state) do
    Logger.warning("unhandled call to #{__MODULE__}: #{inspect(other)}. From: #{inspect(from)}")
    {:reply, :not_implemented, state}
  end

  @impl true
  def handle_cast(other, state) do
    Logger.warning("unhandled cast to #{__MODULE__}: #{inspect(other)}.")
    {:noreply, state}
  end

  @impl true
  def handle_info({:startup, _start_count}, _state) do
    if integration_active?() do
      # Do integration stuff here
    end

    {:noreply, :started}
  end

  def handle_info(other, state) do
    Logger.warning("unhandled message to #{__MODULE__}: #{inspect(other)}.")
    {:noreply, state}
  end

  @spec integration_active?() :: boolean
  defp integration_active?() do
    if Application.get_env(:angen, :test_mode) == true do
      false
    else
      Application.get_env(:angen, :default_site_settings)[:integration_mode]
    end
  end
end
