defmodule Angen.Repo.Migrations.CreateLogTables do
  use Ecto.Migration

  def change do
    # Logging - Server activity
    create_if_not_exists table(:logging_server_minute_logs, primary_key: false) do
      add(:timestamp, :utc_datetime, primary_key: true)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_server_day_logs, primary_key: false) do
      add(:date, :date, primary_key: true)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_server_week_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:week, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_server_month_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:month, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_server_quarter_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:quarter, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_server_year_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    # Logging - Match logs
    create_if_not_exists table(:logging_match_minute_logs, primary_key: false) do
      add(:timestamp, :utc_datetime, primary_key: true)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_match_day_logs, primary_key: false) do
      add(:date, :date, primary_key: true)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_match_week_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:week, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_match_month_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:month, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_match_quarter_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:quarter, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end

    create_if_not_exists table(:logging_match_year_logs, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:date, :date)
      add(:data, :jsonb)
    end
  end
end
