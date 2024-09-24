defmodule Angen.Helper.DateTimeHelper do
  @moduledoc false

  @spec to_datetime(Date.t() | DateTime.t()) :: DateTime.t()
  def to_datetime(%Date{} = d), do: DateTime.new!(d, ~T[00:00:00.0])

  @spec today() :: Date.t()
  def today() do
    DateTime.utc_now()
    |> DateTime.to_date()
  end

  @spec strftime(DateTime.t(), atom) :: String.t()
  def strftime(the_time, :hms_or_ymd) do
    time_date = DateTime.to_date(the_time)
    today_date = today() |> DateTime.to_date()

    if Date.compare(time_date, today_date) == :eq do
      Calendar.strftime(the_time, "%X")
    else
      Calendar.strftime(the_time, "%x")
    end
  end

  def strftime(the_time, :ymd_hms) do
    Calendar.strftime(the_time, "%Y-%m-%d %I:%M:%S")
  end

  # TODO: Remove these
  def date_to_str(the_time), do: strftime(the_time, :hms_or_ymd)
  def date_to_str(the_time, :hms_or_ymd), do: strftime(the_time, :hms_or_ymd)

  def represent_minutes(nil), do: nil

  def represent_minutes(s) do
    represent_seconds(s * 60)
  end

  def represent_seconds(nil), do: nil
  def represent_seconds(0), do: "0 seconds"

  def represent_seconds(s) do
    now = DateTime.utc_now()
    until = DateTime.shift(now, second: s)
    time_until(until, now)
  end

  @spec time_until(DateTime.t()) :: String.t()
  @spec time_until(DateTime.t(), DateTime.t()) :: String.t()
  def time_until(the_time), do: time_until(the_time, DateTime.utc_now())
  def time_until(nil, _), do: nil

  def time_until(time1, time2) do
    days = DateTime.diff(time1, time2, :day)
    hours = DateTime.diff(time1, time2, :hour) - days * 24
    minutes = DateTime.diff(time1, time2, :minute) - days * 1440

    cond do
      # 2 or more days
      days >= 2 ->
        "#{days} days"

      # At least 24 hours
      days == 1 ->
        if hours == 1 do
          "1 day, 1 hour"
        else
          "1 day, #{hours} hours"
        end

      # At least two hours
      hours > 1 ->
        "#{hours} hours"

      # Minutes
      minutes > 3 ->
        "#{hours * 60 + minutes} minutes"

      true ->
        seconds = DateTime.diff(time1, time2, :second)

        if seconds == 1 do
          "1 seconds"
        else
          "#{seconds} seconds"
        end
    end
  end

  @spec beginning_of_day(Date.t() | DateTime.t()) :: DateTime.t()
  def beginning_of_day(datetime) do
    datetime
    |> DateTime.to_date()
    |> to_datetime()
  end

  @spec beginning_of_quarter(Date.t()) :: Date.t()
  def beginning_of_quarter(date) do
    quarter = Date.quarter_of_year(date)
    Date.new!(date.year, (quarter - 1) * 3 + 1, 1)
  end

  @spec beginning_of_year(Date.t()) :: Date.t()
  def beginning_of_year(date) do
    Date.new!(date.year, 1, 1)
  end

  @spec iso_week(Date.t()) :: any
  def iso_week(date) do
    :calendar.iso_week_number({date.year, date.month, date.day})
  end
end
