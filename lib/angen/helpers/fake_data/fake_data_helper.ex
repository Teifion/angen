defmodule Angen.Helpers.FakeDataHelper do
  @moduledoc false
  alias Angen.Helper.DateTimeHelper

  @spec valid_user_ids(DateTime.t()) :: [Teiserver.user_id()]
  def valid_user_ids(before_datetime) do
    Teiserver.Account.list_users(
      where: [
        inserted_before: before_datetime
      ],
      limit: :infinity,
      select: [:id]
    )
    |> Enum.map(fn %{id: id} -> id end)
  end

  @spec valid_user_ids(DateTime.t(), DateTime.t()) :: [Teiserver.user_id()]
  def valid_user_ids(before_datetime, after_datetime) do
    Teiserver.Account.list_users(
      where: [
        inserted_after: after_datetime,
        inserted_before: before_datetime
      ],
      limit: :infinity,
      select: [:id]
    )
    |> Enum.map(fn %{id: id} -> id end)
  end

  @spec matches_this_day(DateTime.t()) :: [Teiserver.match_id()]
  def matches_this_day(date) do
    start_date = DateTimeHelper.beginning_of_day(date)
    end_date = DateTime.shift(start_date, day: 1)

    Teiserver.Game.list_matches(
      where: [
        started_after: start_date,
        started_before: end_date
      ],
      limit: :infinity,
      select: [:id]
    )
    |> Enum.map(fn %{id: id} -> id end)
  end

  @spec rand_int(integer(), integer(), integer()) :: integer()
  def rand_int(lower_bound, upper_bound, existing) do
    range = upper_bound - lower_bound
    max_change = round(range / 3)

    existing = existing || (lower_bound + upper_bound) / 2

    # Create a random +/- change
    change =
      if max_change < 1 do
        0
      else
        :rand.uniform(max_change * 2) - max_change
      end

    (existing + change)
    |> min(upper_bound)
    |> max(lower_bound)
    |> round()
  end

  @spec rand_int_sequence(number(), number(), number(), non_neg_integer()) :: list
  def rand_int_sequence(lower_bound, upper_bound, start_point, iterations) do
    1..iterations
    |> Enum.reduce([start_point], fn _, acc ->
      last_value = hd(acc)
      v = rand_int(lower_bound, upper_bound, last_value)

      [v | acc]
    end)
    |> Enum.reverse()
  end

  @spec random_time_in_day(Date.t() | DateTime.t()) :: DateTime.t()
  def random_time_in_day(%DateTime{} = day_datetime) do
    random_time_in_day(DateTime.to_date(day_datetime))
  end

  def random_time_in_day(day) do
    DateTime.new!(day, Time.new!(
      :rand.uniform(24) - 1,
      :rand.uniform(60) - 1,
      :rand.uniform(60) - 1
    ))
  end
end
