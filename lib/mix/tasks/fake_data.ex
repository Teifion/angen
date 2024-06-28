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
      # Not sure but this appears not to be working
      # TODO: Fix this
      Logger.configure(level: :warning)

      config = parse_args(args)

      start_time = System.system_time(:second)

      # Start by rebuilding the database
      Mix.Task.run("ecto.reset")

      _root_user = add_root_user()

      Angen.FakeData.FakeAccounts.make_accounts(config)
      Angen.FakeData.FakeMatches.make_matches(config)
      Angen.FakeData.FakeTelemetry.make_events(config)
      Angen.FakeData.FakeLogging.make_logs(config)

      make_one_time_code(config)

      elapsed = System.system_time(:second) - start_time

      sizes = get_table_sizes()
      :timer.sleep(50)

      {target_size, total_rows} = sizes
        |> Enum.reduce({0, 0}, fn ([name, row_count], {size_acc, count_acc}) ->
          {
            max(String.length(name), size_acc),
            count_acc + row_count
          }
        end)

      IO.puts "#{String.pad_trailing("Table", target_size)} | Rows"
      sizes
      |> Enum.each(fn [table, row_count] ->
        padded_name = String.pad_trailing(table, target_size)

        IO.puts "#{padded_name} | #{Angen.Helper.StringHelper.format_number(row_count)}"
      end)
      IO.puts ""

      IO.puts(
        "\nFake data insertion complete.\nTook #{elapsed} seconds, inserted #{Angen.Helper.StringHelper.format_number(total_rows)} rows for #{config.days} days of data. You can now login with the email 'root@localhost' and password 'password'.\nA one-time link has been created: http://localhost:4000/login/fakedata_code\n"
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

  defp get_table_sizes() do
    query = """
      WITH tbl AS
        (SELECT table_schema,
                TABLE_NAME
        FROM information_schema.tables
        WHERE TABLE_NAME not like 'pg_%'
          AND table_schema in ('public'))
      SELECT TABLE_NAME,
            (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I.%I', table_schema, TABLE_NAME), FALSE, TRUE, '')))[1]::text::int AS rows_n
      FROM tbl
      ORDER BY rows_n DESC;
    """

    results = case Ecto.Adapters.SQL.query(Angen.Repo, query, []) do
      {:ok, results} ->
        results.rows
        |> Enum.reject(fn [_, row_count] -> row_count <= 0 end)

      {a, b} ->
        raise "ERR: #{a}, #{b}"
    end

    results
  end
end
