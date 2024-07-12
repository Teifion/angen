defmodule Angen.FakeData.FakeAccounts do
  @moduledoc false

  alias Teiserver.Account
  import Angen.Helpers.FakeDataHelper, only: [random_time_in_day: 1]

  @bar_format [
    left: [IO.ANSI.green, String.pad_trailing("Accounts: ", 20), IO.ANSI.reset, " |"]
  ]

  def make_accounts(config) do
    root_user = Account.get_user_by_email("root@localhost")

    range_max = (config.days + 1)

    new_users =
      0..range_max
      |> Enum.map(fn day ->
        ProgressBar.render(day, range_max, @bar_format)

        # Make an extra 50 users for the first day
        users_to_make =
          if day == config.days + 1 do
            50
          else
            users_per_day()
          end

        date = Timex.today() |> Timex.shift(days: -day)

        0..users_to_make
        |> Enum.map(fn _ ->
          random_time = random_time_in_day(date)

          %{
            id: Teiserver.uuid(),
            name: Account.generate_guest_name(),
            email: Teiserver.uuid(),
            password: root_user.password,
            groups: ["admin"],
            permissions: ["admin"],
            inserted_at: random_time,
            updated_at: random_time
          }
        end)
      end)
      |> List.flatten()

    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, Account.User, new_users)
    |> Angen.Repo.transaction()
  end

  defp users_per_day, do: :rand.uniform(3)
end
