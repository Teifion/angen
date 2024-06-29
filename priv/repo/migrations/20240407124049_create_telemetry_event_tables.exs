defmodule Angen.Repo.Migrations.CreateTelemetryEventTables do
  use Ecto.Migration

  def change do
    # Telemetry tables
    create_if_not_exists table(:telemetry_event_types) do
      add(:category, :string)
      add(:name, :string)
    end

    create_if_not_exists(unique_index(:telemetry_event_types, [:category, :name]))

    # Anon
    # ClientApp
    create table(:telemetry_simple_anon_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:hash_id, :uuid)
      add(:inserted_at, :utc_datetime)
    end

    create_if_not_exists(index(:telemetry_simple_anon_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_simple_anon_events, [:hash_id]))

    create table(:telemetry_complex_anon_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:hash_id, :uuid)
      add(:inserted_at, :utc_datetime)
      add(:details, :jsonb)
    end

    create_if_not_exists(index(:telemetry_complex_anon_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_complex_anon_events, [:hash_id]))

    # ClientApp
    create table(:telemetry_simple_clientapp_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
    end

    create_if_not_exists(index(:telemetry_simple_clientapp_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_simple_clientapp_events, [:user_id]))

    create table(:telemetry_complex_clientapp_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
      add(:details, :jsonb)
    end

    create_if_not_exists(index(:telemetry_complex_clientapp_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_complex_clientapp_events, [:user_id]))

    # Lobby
    create table(:telemetry_simple_lobby_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
    end

    create_if_not_exists(index(:telemetry_simple_lobby_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_simple_lobby_events, [:user_id]))
    create_if_not_exists(index(:telemetry_simple_lobby_events, [:match_id]))

    create table(:telemetry_complex_lobby_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
      add(:details, :jsonb)
    end

    create_if_not_exists(index(:telemetry_complex_lobby_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_complex_lobby_events, [:user_id]))
    create_if_not_exists(index(:telemetry_complex_lobby_events, [:match_id]))

    # Match
    create table(:telemetry_simple_match_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:game_time_seconds, :integer)
      add(:inserted_at, :utc_datetime)
    end

    create_if_not_exists(index(:telemetry_simple_match_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_simple_match_events, [:user_id]))
    create_if_not_exists(index(:telemetry_simple_match_events, [:match_id]))

    create table(:telemetry_complex_match_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
      add(:game_time_seconds, :integer)
      add(:details, :jsonb)
    end

    create_if_not_exists(index(:telemetry_complex_match_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_complex_match_events, [:user_id]))
    create_if_not_exists(index(:telemetry_complex_match_events, [:match_id]))

    # Server
    create table(:telemetry_simple_server_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
    end

    create_if_not_exists(index(:telemetry_simple_server_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_simple_server_events, [:user_id]))

    create table(:telemetry_complex_server_events) do
      add(:event_type_id, references(:telemetry_event_types, on_delete: :nothing))
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:inserted_at, :utc_datetime)
      add(:details, :jsonb)
    end

    create_if_not_exists(index(:telemetry_complex_server_events, [:event_type_id]))
    create_if_not_exists(index(:telemetry_complex_server_events, [:user_id]))
  end
end
