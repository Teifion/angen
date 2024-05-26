defmodule Mix.Tasks.Angen.Fakedata do
  @moduledoc """
  Run with mix angen.fakedata

  You can override some of the options with:

  mix angen.fakedata days:5
  """

  use Mix.Task

  alias Angen.{Logging}
  alias Teiserver.{Account}
  require Logger

  @defaults %{
    days: 7
  }

  defp users_per_day, do: :rand.uniform(5) + 2

  @spec parse_args(list()) :: map()
  defp parse_args(args) do
    args
    |> Enum.reduce(@defaults, fn
      ("days:" <> day_str, acc) ->
        Map.put(acc, :days, String.to_integer(day_str))

    end)
  end

  @spec run(list()) :: :ok
  def run(args) do
    if Application.get_env(:angen, :enfys_mode) do
      config = parse_args(args)

      start_time = System.system_time(:second)

      # Start by rebuilding the database
      Mix.Task.run("ecto.reset")

      # Accounts
      make_accounts(config)

      Angen.FakeData.FakeLogging.make_logs(config)

      # make_matches(config)
      # make_telemetry(config)
      # make_moderation(config)
      # make_one_time_code(config)

      :timer.sleep(50)

      elapsed = System.system_time(:second) - start_time

      IO.puts(
        "\nFake data insertion complete. You can now login with the email 'root@localhost' and password 'password'.\nTook #{elapsed} seconds."
        #A one-time link has been created: http://localhost:4000/login/fakedata_code\n"
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

  defp make_accounts(config) do
    root_user = add_root_user()

    new_users =
      Range.new(0, config.days)
      |> Enum.map(fn day ->
        # Make an extra 50 users for the first day
        users_to_make = if day == config.days do
          50
        else
          users_per_day()
        end

        Range.new(0, users_to_make)
        |> Enum.map(fn _ ->
          minutes = :rand.uniform(24 * 60)

          %{
            id: Teiserver.uuid(),
            name: Account.generate_guest_name(),
            email: Teiserver.uuid(),
            password: root_user.password,
            groups: ["admin"],
            permissions: ["admin"],
            inserted_at: Timex.shift(Timex.now(), days: -day, minutes: -minutes) |> time_convert,
            updated_at: Timex.shift(Timex.now(), days: -day, minutes: -minutes) |> time_convert
          }
        end)
      end)
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Teiserver.Account.User, new_users)
    |> Angen.Repo.transaction()
  end

  # defp make_one_time_code() do
  #   root_user = Account.get_user_by_email("root@localhost")

  #   Teiserver.Config.update_site_config("user.Enable one time links", "true")

  #   {:ok, _code} =
  #     Account.create_code(%{
  #       value: "fakedata_code$127.0.0.1",
  #       purpose: "one_time_login",
  #       expires: Timex.now() |> Timex.shift(hours: 24),
  #       user_id: root_user.id
  #     })
  # end

  def time_convert(t) do
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

  def valid_userids(datetime) do
    Teiserver.Account.list_users(
      where: [
        inserted_after: Timex.to_datetime(datetime)
      ],
      select: [:id]
    )
    |> Enum.map(fn %{id: id} -> id end)
  end

  @spec rand_int(integer(), integer(), integer()) :: integer()
  def rand_int(lower_bound, upper_bound, existing) do
    range = upper_bound - lower_bound
    max_change = round(range/3)

    existing = existing || ((lower_bound + upper_bound) / 2)

    # Create a random +/- change
    change = if max_change < 1 do
      0
    else
      (:rand.uniform(max_change * 2) - max_change)
    end

    (existing + change)
      |> min(upper_bound)
      |> max(lower_bound)
      |> round()
  end

  @spec rand_int_sequence(number(), number(), number(), non_neg_integer()) :: list
  def rand_int_sequence(lower_bound, upper_bound, start_point, iterations) do
    Range.new(1, iterations)
    |> Enum.reduce([start_point], fn (_, acc) ->
      last_value = hd(acc)
      v = rand_int(lower_bound, upper_bound, last_value)

      [v | acc]
    end)
    |> Enum.reverse()
  end
end
