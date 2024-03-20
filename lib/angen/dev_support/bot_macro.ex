defmodule Angen.DevSupport.BotMacro do
  @moduledoc """
  Apply to bots with `use Angen.DevSupport.BotMacro`
  """
  @callback handle(map(), Angen.ConnState.t()) :: Angen.handler_response()

  @spec __using__(any) :: Macro.t()
  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Angen.DevSupport.BotMacro

      use GenServer
      alias Teiserver.Api
      alias Angen.DevSupport.BotLib

      def start_link(params, _opts \\ []) do
        GenServer.start_link(
          __MODULE__,
          params,
          name: __MODULE__
        )
      end

      @impl GenServer
      def init(params) do
        {:ok, %{params: params}}
      end

      @impl GenServer
      def handle_call(other, from, state) do
        Logger.warning("unhandled call to ClusterManager: #{inspect(other)}. From: #{inspect(from)}")
        {:reply, :not_implemented, state}
      end

      @impl GenServer
      def handle_cast(other, state) do
        Logger.warning("unhandled cast to ClusterManager: #{inspect(other)}.")
        {:noreply, state}
      end
    end
  end
end
