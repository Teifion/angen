defmodule Angen.Fixtures.LoggingFixtures do
  @moduledoc false
  alias Angen.Logging

  # Match logs
  @spec match_minute_log_fixture() :: Logging.MatchMinuteLog.t()
  @spec match_minute_log_fixture(map) :: Logging.MatchMinuteLog.t()
  def match_minute_log_fixture(data \\ %{}) do
    Logging.MatchMinuteLog.changeset(
      %Logging.MatchMinuteLog{},
      %{
        timestamp: data[:timestamp] || Timex.now(),
        node: data[:node] || "test-node",
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec match_day_log_fixture() :: Logging.MatchDayLog.t()
  @spec match_day_log_fixture(map) :: Logging.MatchDayLog.t()
  def match_day_log_fixture(data \\ %{}) do
    Logging.MatchDayLog.changeset(
      %Logging.MatchDayLog{},
      %{
        date: data[:date] || Timex.today(),
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec match_week_log_fixture() :: Logging.MatchWeekLog.t()
  @spec match_week_log_fixture(map) :: Logging.MatchWeekLog.t()
  def match_week_log_fixture(data \\ %{}) do
    Logging.MatchWeekLog.changeset(
      %Logging.MatchWeekLog{},
      %{
        date: data[:date] || Timex.today(),
        year: data[:year] || 1,
        week: data[:week] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec match_month_log_fixture() :: Logging.MatchMonthLog.t()
  @spec match_month_log_fixture(map) :: Logging.MatchMonthLog.t()
  def match_month_log_fixture(data \\ %{}) do
    Logging.MatchMonthLog.changeset(
      %Logging.MatchMonthLog{},
      %{
        date: data[:date] || Timex.today(),
        year: data[:year] || 1,
        month: data[:month] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec match_quarter_log_fixture() :: Logging.MatchQuarterLog.t()
  @spec match_quarter_log_fixture(map) :: Logging.MatchQuarterLog.t()
  def match_quarter_log_fixture(data \\ %{}) do
    Logging.MatchQuarterLog.changeset(
      %Logging.MatchQuarterLog{},
      %{
        date: data[:date] || Timex.today(),
        year: data[:year] || 1,
        quarter: data[:quarter] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end

  @spec match_year_log_fixture() :: Logging.MatchYearLog.t()
  @spec match_year_log_fixture(map) :: Logging.MatchYearLog.t()
  def match_year_log_fixture(data \\ %{}) do
    Logging.MatchYearLog.changeset(
      %Logging.MatchYearLog{},
      %{
        date: data[:date] || Timex.today(),
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
        timestamp: data[:timestamp] || Timex.now(),
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
        date: data[:date] || Timex.today(),
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
        date: data[:date] || Timex.today(),
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
        date: data[:date] || Timex.today(),
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
        date: data[:date] || Timex.today(),
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
        date: data[:date] || Timex.today(),
        year: data[:year] || 1,
        data: data[:data] || %{}
      }
    )
    |> Angen.Repo.insert!()
  end
end
