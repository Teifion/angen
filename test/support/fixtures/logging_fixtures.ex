defmodule Angen.Fixtures.LoggingFixtures do
  @moduledoc false
  alias Angen.Logging
  alias Teiserver.Logging.AuditLog
  import Angen.Fixtures.AccountFixtures, only: [user_fixture: 0]
  alias Angen.Helper.DateTimeHelper

  # Copied straight from Teiserver repo
  @spec audit_log_fixture(map) :: AuditLog.t()
  def audit_log_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    AuditLog.changeset(
      %AuditLog{},
      %{
        action: data[:action] || "action_#{r}",
        details: data[:details] || %{},
        ip: data[:ip] || "ip_#{r}",
        user_id: data[:user_id] || user_fixture().id
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec anonymous_audit_log_fixture(map) :: AuditLog.t()
  def anonymous_audit_log_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    AuditLog.changeset(
      %AuditLog{},
      %{
        action: data[:action] || "action_#{r}",
        details: data[:details] || %{},
        ip: data[:ip] || "ip_#{r}",
        user_id: nil
      }
    )
    |> Angen.Repo.insert!()
  end

  # Match logs
  @spec game_day_log_fixture() :: Logging.GameDayLog.t()
  @spec game_day_log_fixture(map) :: Logging.GameDayLog.t()
  def game_day_log_fixture(data \\ %{}) do
    Logging.GameDayLog.changeset(
      %Logging.GameDayLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec game_week_log_fixture() :: Logging.GameWeekLog.t()
  @spec game_week_log_fixture(map) :: Logging.GameWeekLog.t()
  def game_week_log_fixture(data \\ %{}) do
    Logging.GameWeekLog.changeset(
      %Logging.GameWeekLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        week: data[:week] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec game_month_log_fixture() :: Logging.GameMonthLog.t()
  @spec game_month_log_fixture(map) :: Logging.GameMonthLog.t()
  def game_month_log_fixture(data \\ %{}) do
    Logging.GameMonthLog.changeset(
      %Logging.GameMonthLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        month: data[:month] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec game_quarter_log_fixture() :: Logging.GameQuarterLog.t()
  @spec game_quarter_log_fixture(map) :: Logging.GameQuarterLog.t()
  def game_quarter_log_fixture(data \\ %{}) do
    Logging.GameQuarterLog.changeset(
      %Logging.GameQuarterLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        quarter: data[:quarter] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec game_year_log_fixture() :: Logging.GameYearLog.t()
  @spec game_year_log_fixture(map) :: Logging.GameYearLog.t()
  def game_year_log_fixture(data \\ %{}) do
    Logging.GameYearLog.changeset(
      %Logging.GameYearLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  # Server logs
  @spec server_minute_log_fixture() :: Logging.ServerMinuteLog.t()
  @spec server_minute_log_fixture(map) :: Logging.ServerMinuteLog.t()
  def server_minute_log_fixture(data \\ %{}) do
    Logging.ServerMinuteLog.changeset(
      %Logging.ServerMinuteLog{},
      %{
        timestamp: data[:timestamp] || DateTime.utc_now(),
        node: data[:node] || "test-node",
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec server_day_log_fixture() :: Logging.ServerDayLog.t()
  @spec server_day_log_fixture(map) :: Logging.ServerDayLog.t()
  def server_day_log_fixture(data \\ %{}) do
    Logging.ServerDayLog.changeset(
      %Logging.ServerDayLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec server_week_log_fixture() :: Logging.ServerWeekLog.t()
  @spec server_week_log_fixture(map) :: Logging.ServerWeekLog.t()
  def server_week_log_fixture(data \\ %{}) do
    Logging.ServerWeekLog.changeset(
      %Logging.ServerWeekLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        week: data[:week] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec server_month_log_fixture() :: Logging.ServerMonthLog.t()
  @spec server_month_log_fixture(map) :: Logging.ServerMonthLog.t()
  def server_month_log_fixture(data \\ %{}) do
    Logging.ServerMonthLog.changeset(
      %Logging.ServerMonthLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        month: data[:month] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec server_quarter_log_fixture() :: Logging.ServerQuarterLog.t()
  @spec server_quarter_log_fixture(map) :: Logging.ServerQuarterLog.t()
  def server_quarter_log_fixture(data \\ %{}) do
    Logging.ServerQuarterLog.changeset(
      %Logging.ServerQuarterLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        quarter: data[:quarter] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec server_year_log_fixture() :: Logging.ServerYearLog.t()
  @spec server_year_log_fixture(map) :: Logging.ServerYearLog.t()
  def server_year_log_fixture(data \\ %{}) do
    Logging.ServerYearLog.changeset(
      %Logging.ServerYearLog{},
      %{
        date: data[:date] || DateTimeHelper.today(),
        year: data[:year] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end
end
