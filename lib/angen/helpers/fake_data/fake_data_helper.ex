defmodule Angen.Helpers.FakeDataHelper do
  @moduledoc false


  def random_pick_from(list, chance \\ 0.5) do
    list
    |> Enum.filter(fn _ ->
      :rand.uniform() < chance
    end)
  end

  def valid_userids(before_datetime) do
    Teiserver.Account.list_users(
      where: [
        inserted_before: Timex.to_datetime(before_datetime)
      ],
      limit: :infinity,
      select: [:id]
    )
    |> Enum.map(fn %{id: id} -> id end)
  end

  def valid_userids(before_datetime, after_datetime) do
    Teiserver.Account.list_users(
      where: [
        inserted_after: Timex.to_datetime(after_datetime),
        inserted_before: Timex.to_datetime(before_datetime)
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

  def random_time_in_day(date) do
    date
    |> Timex.to_datetime()
    |> Timex.set(
      hour: :rand.uniform(24) - 1,
      minute: :rand.uniform(60) - 1,
      second: :rand.uniform(60) - 1
    )
    |> DateTime.truncate(:second)
  end
end
