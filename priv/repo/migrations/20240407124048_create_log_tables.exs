defmodule Angen.Repo.Migrations.CreateLogTables do
  use Ecto.Migration

  def change do
    # Logging - Server activity
    create_if_not_exists table(:logging_server_minute_logs, primary_key: false) do
      add(:timestamp, :utc_datetime, primary_key: true)
      add(:node, :string, primary_key: true)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_server_day_logs, primary_key: false) do
      add(:date, :date, primary_key: true)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_server_day_logs, [:date]))

    create_if_not_exists table(:logging_server_week_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:week, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_server_week_logs, [:date]))

    create_if_not_exists table(:logging_server_month_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:month, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_server_month_logs, [:date]))

    create_if_not_exists table(:logging_server_quarter_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:quarter, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_server_quarter_logs, [:date]))

    create_if_not_exists table(:logging_server_year_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_server_year_logs, [:date]))

    # Logging - Match logs
    create_if_not_exists table(:logging_game_day_logs, primary_key: false) do
      add(:date, :date, primary_key: true)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_game_day_logs, [:date]))

    create_if_not_exists table(:logging_game_week_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:week, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_game_week_logs, [:date]))

    create_if_not_exists table(:logging_game_month_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:month, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_game_month_logs, [:date]))

    create_if_not_exists table(:logging_game_quarter_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:quarter, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_game_quarter_logs, [:date]))

    create_if_not_exists table(:logging_game_year_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
    create_if_not_exists(index(:logging_game_year_logs, [:date]))
  end
end
