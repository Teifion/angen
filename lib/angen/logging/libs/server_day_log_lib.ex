defmodule Angen.Logging.ServerDayLogLib do
  @moduledoc """
  Library of server_day_log related functions.
  """
  use TeiserverMacros, :library
  alias Angen.Logging.{ServerDayLog, ServerDayLogQueries}

  @doc """
  Returns the list of server_day_logs.

  ## Examples

      iex> list_server_day_logs()
      [%ServerDayLog{}, ...]

  """
  @spec list_server_day_logs(Teiserver.query_args()) :: [ServerDayLog.t()]
  def list_server_day_logs(query_args) do
    query_args
    |> ServerDayLogQueries.server_day_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_day_log.

  Raises `Ecto.NoResultsError` if the ServerDayLog does not exist.

  ## Examples

      iex> get_server_day_log!(123)
      %ServerDayLog{}

      iex> get_server_day_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_day_log!(Date.t(), Teiserver.query_args()) :: ServerDayLog.t()
  def get_server_day_log!(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerDayLogQueries.server_day_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_day_log.

  Returns nil if the ServerDayLog does not exist.

  ## Examples

      iex> get_server_day_log(123)
      %ServerDayLog{}

      iex> get_server_day_log(456)
      nil

  """
  @spec get_server_day_log(Date.t(), Teiserver.query_args()) :: ServerDayLog.t() | nil
  def get_server_day_log(date, query_args \\ []) do
    (query_args ++ [date: date])
    |> ServerDayLogQueries.server_day_log_query()
    |> Repo.one()
  end

  @doc """
  Gets the date of the last ServerMinuteLog in the database, returns nil if there are none.
  """
  @spec get_last_server_day_log_date() :: Date.t() | nil
  def get_last_server_day_log_date() do
    log =
      ServerDayLogQueries.server_day_log_query(
        order_by: "Newest first",
        select: [:date],
        limit: 1
      )
      |> Repo.one()

    case log do
      nil -> nil
      %{date: date} -> date
    end
  end

  @doc """
  Creates a server_day_log.

  ## Examples

      iex> create_server_day_log(%{field: value})
      {:ok, %ServerDayLog{}}

      iex> create_server_day_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_day_log(map) :: {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  def create_server_day_log(attrs) do
    %ServerDayLog{}
    |> ServerDayLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_day_log.

  ## Examples

      iex> update_server_day_log(server_day_log, %{field: new_value})
      {:ok, %ServerDayLog{}}

      iex> update_server_day_log(server_day_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_day_log(ServerDayLog.t(), map) ::
          {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  def update_server_day_log(%ServerDayLog{} = server_day_log, attrs) do
    server_day_log
    |> ServerDayLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_day_log.

  ## Examples

      iex> delete_server_day_log(server_day_log)
      {:ok, %ServerDayLog{}}

      iex> delete_server_day_log(server_day_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_day_log(ServerDayLog.t()) ::
          {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_day_log(%ServerDayLog{} = server_day_log) do
    Repo.delete(server_day_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_day_log changes.

  ## Examples

      iex> change_server_day_log(server_day_log)
      %Ecto.Changeset{data: %ServerDayLog{}}

  """
  @spec change_server_day_log(ServerDayLog.t(), map) :: Ecto.Changeset.t()
  def change_server_day_log(%ServerDayLog{} = server_day_log, attrs \\ %{}) do
    ServerDayLog.changeset(server_day_log, attrs)
  end

  # Aggregation stuff
  @user_types ~w(menu lobby player spectator bot total_inc_bot total_non_bot)
  @event_types ~w(simple_anon complex_anon simple_clientapp complex_clientapp simple_lobby complex_lobby simple_match complex_match simple_server complex_server)

  # Lists mean a value from each day
  # Maps mean total for the block of that key
  # Integers means sum or average
  @empty_segment %{
    peak_user_counts: @user_types |> Map.new(fn t -> {t, 0} end),
    minutes: @user_types |> Map.new(fn t -> {t, 0} end),
    telemetry_events: @event_types |> Map.new(fn t -> {t, %{}} end),
    stats: %{
      accounts_created: 0
    }
  }

  @spec aggregate_day_logs([ServerDayLog]) :: map()
  def aggregate_day_logs(logs) do
    logs
    |> Enum.reduce(@empty_segment, fn log, acc ->
      extend_segment(acc, log)
    end)
  end

  # Given an existing segment and a batch of logs, calculate the segment and add them together
  defp extend_segment(existing, %{data: data} = _day_log) do
    %{
      telemetry_events:
        @event_types
        |> Map.new(fn t ->
          {t,
           add_maps(
             Map.get(existing.telemetry_events, t, %{}),
             get_in(data, ["telemetry_events", t])
           )}
        end),
      peak_user_counts:
        @user_types
        |> Map.new(fn t ->
          {t,
           max(Map.get(existing.peak_user_counts, t, %{}), get_in(data, ["peak_user_counts", t]))}
        end),
      minutes:
        @user_types
        |> Map.new(fn t ->
          {t, max(Map.get(existing.minutes, t, %{}), get_in(data, ["minutes", t]))}
        end),
      stats: %{
        accounts_created:
          existing.stats.accounts_created + get_in(data, ["stats", "accounts_created"])
      }
    }
  end

  @spec calculate_period_statistics(Date.t(), Date.t()) :: map()
  def calculate_period_statistics(start_date, end_date) do
    %{
      accounts_created: get_accounts_created(start_date, end_date),
      unique_users: get_unique_users(start_date, end_date),
      unique_players: get_unique_players(start_date, end_date)
    }
  end

  defp get_accounts_created(start_date, end_date) do
    Teiserver.Account.user_query(
      where: [
        inserted_after: start_date |> Timex.to_datetime(),
        inserted_before: end_date |> Timex.to_datetime(),
        smurf_of: false,
        not_has_group: "guest",
        not_has_restriction: "login"
      ],
      limit: :infinity
    )
    |> Angen.Repo.aggregate(:count)
  end

  defp get_unique_players(_start_date, _end_date) do
    # Need match memberships to get this
    -1
  end

  defp get_unique_users(start_date, end_date) do
    event_type_id = Angen.Telemetry.get_or_add_event_type_id("connected", "simple_clientapp")

    # We add 1000 because otherwise it comes back as a charlist and borks a bunch of stuff
    query = """
      SELECT count(DISTINCT user_id) + 1000
      FROM telemetry_simple_clientapp_events
      WHERE event_type_id = $1
        AND inserted_at >= $2
        AND inserted_at < $3
    """

    case Ecto.Adapters.SQL.query(Angen.Repo, query, [
           event_type_id,
           Timex.to_datetime(start_date),
           Timex.to_datetime(end_date)
         ]) do
      {:ok, %{rows: [[result]]}} ->
        result - 1000

      {a, b} ->
        raise "ERR: #{a}, #{b}"
    end
  end

  defp add_maps(m1, nil), do: m1

  defp add_maps(m1, m2) do
    Map.merge(m1, m2, fn _k, v1, v2 -> v1 + v2 end)
  end
end
