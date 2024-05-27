defmodule Angen.Repo.Migrations.CreateTelemetryEventTables do
  use Ecto.Migration

  def change do
    # Telemetry tables
    create_if_not_exists table(:telemetry_event_types) do
      add(:category, :string)
      add(:name, :string)
    end

    create_if_not_exists(unique_index(:telemetry_event_types, [:category, :name]))

    # Client App stuff
    create table(:telemetry_simple_clientapp_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
    end

    create table(:teiserver_telemetry_client_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
      add(:details, :jsonb)
    end
  end
end
