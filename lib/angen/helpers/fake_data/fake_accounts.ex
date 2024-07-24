defmodule Angen.FakeData.FakeAccounts do
  @moduledoc false

  alias Teiserver.Account
  alias Angen.Repo
  import Angen.Helpers.FakeDataHelper, only: [random_time_in_day: 1]
  import Angen.Helper.TimexHelper, only: [date_to_str: 2]

  @bar_format [
    left: [IO.ANSI.green(), String.pad_trailing("Accounts: ", 20), IO.ANSI.reset(), " |"]
  ]

  @spec make_accounts(map) :: any
  def make_accounts(config) do
    root_user = Account.get_user_by_email("root@localhost")

    range_max = config.days + 1

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
            groups: [],
            permissions: [],
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

  @spec update_accounts(map) :: any
  def update_accounts(_config) do
    # Get last played for each account
    query = """
      SELECT mm.user_id, MAX(m.lobby_opened_at), MAX(m.match_ended_at)
      FROM game_match_memberships mm
      JOIN game_matches m
        ON mm.match_id = m.id
      GROUP BY mm.user_id
    """

    {:ok, %{rows: rows}} = Ecto.Adapters.SQL.query(Repo, query, [])

    rows
    |> Enum.each(fn [user_id, lobby_opened_at, match_ended_at] ->
      logout = Timex.shift(match_ended_at, minutes: 3 + :rand.uniform(120))

      query = """
        UPDATE account_users
        SET last_login_at = '#{date_to_str(lobby_opened_at, :ymd_hms)}',
          last_played_at = '#{date_to_str(match_ended_at, :ymd_hms)}',
          last_logout_at = '#{date_to_str(logout, :ymd_hms)}'
        WHERE id = $1
      """

      {:ok, _} = Ecto.Adapters.SQL.query(Repo, query, [user_id])
    end)
  end
end
