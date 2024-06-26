defmodule Mix.Tasks.Angen.Fakedata do
  @moduledoc """
  Run with mix angen.fakedata

  You can override some of the options with:

  mix angen.fakedata days:5
  """

  use Mix.Task

  alias Teiserver.{Account}
  require Logger

  @defaults %{
    days: 7,
    detail_days: 3
  }

  @spec parse_args(list()) :: map()
  defp parse_args(args) do
    args
    |> Enum.reduce(@defaults, fn
      "days:" <> day_str, acc ->
        Map.put(acc, :days, String.to_integer(day_str))

      "detail-days:" <> day_str, acc ->
        Map.put(acc, :detail_days, String.to_integer(day_str))
    end)
  end

  @spec run(list()) :: :ok
  def run(args) do
    if Application.get_env(:angen, :enfys_mode) do
      config = parse_args(args)

      start_time = System.system_time(:second)

      # Start by rebuilding the database
      Mix.Task.run("ecto.reset")

      _root_user = add_root_user()

      Angen.FakeData.FakeAccounts.make_accounts(config)
      Angen.FakeData.FakeTelemetry.make_events(config)
      Angen.FakeData.FakeLogging.make_logs(config)

      # make_matches(config)
      # make_moderation(config)

      make_one_time_code(config)

      :timer.sleep(50)

      elapsed = System.system_time(:second) - start_time

      IO.puts(
        "\nFake data insertion complete. You can now login with the email 'root@localhost' and password 'password'.\nTook #{elapsed} seconds. A one-time link has been created: http://localhost:4000/login/fakedata_code\n"
      )
    else
      Logger.error("Enfys mode is not enabled, you cannot run the fakedata task")
    end
  end

  defp add_root_user() do
    {:ok, user} =
      Account.create_user(%{
        name: "root",
        email: "root@localhost",
        password: "password",
        groups: ["admin"],
        permissions: ["admin"]
      })

    user
  end

  defp make_one_time_code(_config) do
    root_user = Account.get_user_by_email("root@localhost")

    {:ok, _code} =
      Angen.Account.create_user_token(%{
        user_id: root_user.id,
        id: Teiserver.deterministic_uuid("root@localhost"),
        identifier_code: Angen.Account.UserTokenLib.generate_code(),
        renewal_code: Angen.Account.UserTokenLib.generate_code(),
        context: "fake-data",
        user_agent: "fake-data",
        ip: "127.0.0.1",
        expires_at: Timex.now() |> Timex.shift(days: 31)
      })
  end

  def naive_time(t) do
    t
    |> Timex.to_unix()
    |> Timex.from_unix()
    |> Timex.to_naive_datetime()
  end

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
    Range.new(1, iterations)
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
