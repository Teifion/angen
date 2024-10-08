defmodule Angen.DevSupport.ManagerServer do
  @moduledoc """
  The genserver managing all other DevSupport servers
  """
  use GenServer
  require Logger
  alias Angen.DevSupport

  @startup_delay 500

  @bots [
    # Generic bots
    {DevSupport.LobbyHostIdleBot, %{behaviour: :idle}},
    {DevSupport.LobbyHostIdleBot, %{behaviour: :deny}},
    {DevSupport.LobbyHostIdleBot, %{behaviour: :kick}},
    {DevSupport.LobbyChatEchoBot, %{}},
    {DevSupport.DMEchoBot, %{}},

    # e2e test bots for games
    {DevSupport.LobbyHostPlayBot, %{}},
    {DevSupport.LobbyPlayerBot, %{idx: 1}}
    # {DevSupport.LobbyPlayerBot, %{idx: 2}},
    # {DevSupport.LobbyPlayerBot, %{idx: 3}},
    # {DevSupport.LobbyPlayerBot, %{idx: 4}},
    # {DevSupport.LobbySpectatorBot, %{idx: 1}},
    # {DevSupport.LobbySpectatorBot, %{idx: 2}},
  ]

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
      @bots
      |> Enum.each(fn {bot, params} ->
        start_bot(bot, params)
      end)
    end

    {:noreply, :started}
  end

  def handle_info(other, state) do
    Logger.warning("unhandled message to #{__MODULE__}: #{inspect(other)}.")
    {:noreply, state}
  end

  @spec start_bot(module(), map()) :: {:ok, pid()}
  def start_bot(bot, params) do
    DynamicSupervisor.start_child(
      DevSupport.IntegrationSupervisor,
      {bot, params}
    )
  end

  @spec stop_bot(pid()) :: :ok | {:error, :not_found}
  def stop_bot(pid) do
    DynamicSupervisor.terminate_child(
      DevSupport.IntegrationSupervisor,
      pid
    )
  end

  @spec integration_active?() :: boolean
  def integration_active?() do
    if Application.get_env(:angen, :test_mode) == true do
      false
    else
      Application.get_env(:angen, :integration_mode, false)
    end
  end
end
