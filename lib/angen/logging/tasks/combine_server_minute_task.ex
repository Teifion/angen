defmodule Angen.Logging.CombineServerMinuteTask do
  @moduledoc false
  # Takes the per-node server minute tasks and combines them into a singular
  # `all` node.

  use Oban.Worker, queue: :logging

  alias Angen.Logging

  @impl Oban.Worker
  @spec perform(any()) :: :ok
  def perform(_) do
    now = Timex.now() |> Timex.set(microsecond: 0, second: 0)

    logs = Logging.list_server_minute_logs(
      where: [timestamp: now]
    )

    combined_data = logs
      |> prune_logs
      |> add_all_maps
      |> prune_result
      |> add_totals(logs)

    Logging.create_server_minute_log(%{
      timestamp: now,
      node: "all",
      data: combined_data
    })

    :ok
  end

  # prune data from the logs which we don't want to combine
  @spec prune_logs([map()]) :: [map()]
  def prune_logs(logs) do
    logs
    |> Enum.map(fn %{data: data} ->
      Map.drop(data, ~w(os))
    end)
  end

  @spec add_all_maps([map()]) :: map()
  def add_all_maps(data_list) do
    data_list
    |> Enum.reduce(%{}, &recursively_add_data/2)
  end

  @spec recursively_add_data(any(), any()) :: any()
  def recursively_add_data(v1, nil), do: v1
  def recursively_add_data(nil, v2), do: v2

  def recursively_add_data(m1, m2) when is_map(m1) and is_map(m2) do
    Enum.uniq(Map.keys(m1) ++ Map.keys(m2))
    |> Map.new(fn key ->
      v1 = Map.get(m1, key)
      v2 = Map.get(m2, key)

      {key, recursively_add_data(v1, v2)}
    end)
  end

  def recursively_add_data(l1, l2) when is_list(l1) and is_list(l2) do
    l1 ++ l2
  end

  def recursively_add_data(n1, n2) when is_number(n1) and is_number(n2) do
    n1 + n2
  end

  @spec prune_result(map()) :: map()
  def prune_result(data) do
    new_server_processes = Map.drop(data["server_processes"], ~w(beam_total))
    Map.put(data, "server_processes", new_server_processes)
  end

  @spec add_totals(map(), [map()]) :: map()
  def add_totals(data, logs) do
    totals = %{
      "unique_users" => Horde.Registry.count(Teiserver.ClientRegistry),
      "nodes" => Enum.count(logs)
    }

    Map.put(data, "totals", totals)
  end
end
