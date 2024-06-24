ExUnit.start()

alias Angen.Telemetry

existing_event_types = Telemetry.list_event_types(limit: :infinity)
  |> Enum.map(fn t -> {t.category, t.name} end)

new_event_types = [
  {"simple_clientapp", ["connected", "disconnected"]},
  {"simple_lobby", ["cycle", "start_match"]}
]
|> Enum.map(fn {category, events} ->
  events
  |> Enum.map(fn name ->
    if not Enum.member?(existing_event_types, {category, name}) do
      %{
        category: category,
        name: name
      }
    end
  end)
end)
|> List.flatten
|> Enum.reject(&(&1 == nil))

Ecto.Multi.new()
  |> Ecto.Multi.insert_all(:insert_all, Angen.Telemetry.EventType, new_event_types)
  |> Angen.Repo.transaction()

Ecto.Adapters.SQL.Sandbox.mode(Angen.Repo, :manual)
