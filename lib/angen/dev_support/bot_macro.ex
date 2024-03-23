defmodule Angen.DevSupport.BotMacro do
  @moduledoc """
  Apply to bots with `use Angen.DevSupport.BotMacro`
  """
  # @callback handle(map(), Angen.ConnState.t()) :: Angen.handler_response()

  @spec __using__(any) :: Macro.t()
  defmacro __using__(_opts) do
    quote do
      # @behaviour Angen.DevSupport.BotMacro

      use GenServer
      alias Teiserver.Api
      alias Angen.DevSupport.BotLib
      require Logger

      @spec start_link({handler_options :: term(), GenServer.options()}) :: GenServer.on_start()
      def start_link(params) do
        GenServer.start_link(__MODULE__, params, [])
      end

      @impl GenServer
      def init(params) do
        Logger.info("Startup for #{__MODULE__}")

        Process.send_after(self(), :startup, 1000)
        {:ok, default_state(params)}
      end

      def default_state(params) do
        %{
          params: params,
          user: nil,
          lobby_id: nil,
          connected: false
        }
      end
    end
  end
end
