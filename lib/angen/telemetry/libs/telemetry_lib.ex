defmodule Angen.Telemetry.TelemetryLib do
  @moduledoc false

  @spec event_list() :: [[atom]]
  def event_list() do
    [
      [:angen, :protocol, :response],
      [:angen, :protocol, :response, :start],
      [:angen, :protocol, :response, :stop]
    ]
  end

  @spec get_angen_totals(boolean) :: map()
  def get_angen_totals(reset \\ false) do
    do_get_totals(Angen.Telemetry.AngenCollectorServer, reset)
  end

  @spec get_teiserver_totals(boolean) :: map()
  def get_teiserver_totals(reset \\ false) do
    do_get_totals(Angen.Telemetry.TeiserverCollectorServer, reset)
  end

  @spec get_all_totals(boolean) :: map()
  def get_all_totals(reset \\ false) do
    %{
      angen: get_angen_totals(reset),
      teiserver: get_teiserver_totals(reset),
    }
  end

  @spec do_get_totals(module, boolean) :: map()
  defp do_get_totals(server, reset) do
    cmd = if reset, do: :get_totals_and_reset, else: :get_totals

    try do
      GenServer.call(server, cmd)
      # In certain situations (e.g. just after startup) it can be
      # the process hasn't started up so we need to handle that
      # without dying
    catch
      :exit, _ ->
        %{}
    end

  end
end
