defmodule Angen.Logging do
  @moduledoc """
  The contextual module for:
  - `Angen.Logging.GameDayLog`
  - `Angen.Logging.GameWeekLog`
  - `Angen.Logging.GameQuarterLog`
  - `Angen.Logging.GameYearLog`
  - `Angen.Logging.ServerMinuteLog`
  - `Angen.Logging.ServerDayLog`
  - `Angen.Logging.ServerWeekLog`
  - `Angen.Logging.ServerQuarterLog`
  - `Angen.Logging.ServerYearLog`

  ## Minutes through to years
  The system is designed to take a snapshot of activity every minute and roll these up into day logs at the end of each day. The system then later creates week, month, quarter and year snapshots from the day logs. While we could just roll up the day logs each time we need to make a query the space taken by the extra snapshots is very small and makes querying so much easier I decided to add the extra files/tables.

  Minute to minute logs are deleted periodically to save space but Day logs and beyond are designed to be kept.
  """

  # GameDayLogs
  alias Angen.Logging.{GameDayLog, GameDayLogLib, GameDayLogQueries}

  @doc false
  @spec game_day_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate game_day_log_query(args), to: GameDayLogQueries

  @doc section: :game_day_log
  @spec list_game_day_logs(Teiserver.query_args()) :: [GameDayLog.t()]
  defdelegate list_game_day_logs(args), to: GameDayLogLib

  @doc section: :game_day_log
  @spec get_game_day_log!(Date.t()) :: GameDayLog.t()
  @spec get_game_day_log!(Date.t(), Teiserver.query_args()) :: GameDayLog.t()
  defdelegate get_game_day_log!(date, query_args \\ []), to: GameDayLogLib

  @doc section: :game_day_log
  @spec get_game_day_log(Date.t()) :: GameDayLog.t() | nil
  @spec get_game_day_log(Date.t(), Teiserver.query_args()) :: GameDayLog.t() | nil
  defdelegate get_game_day_log(date, query_args \\ []), to: GameDayLogLib

  @doc section: :game_day_log
  @spec create_game_day_log(map) :: {:ok, GameDayLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_game_day_log(attrs), to: GameDayLogLib

  @doc section: :game_day_log
  @spec update_game_day_log(GameDayLog, map) ::
          {:ok, GameDayLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_game_day_log(game_day_log, attrs), to: GameDayLogLib

  @doc section: :game_day_log
  @spec delete_game_day_log(GameDayLog.t()) ::
          {:ok, GameDayLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_game_day_log(game_day_log), to: GameDayLogLib

  @doc section: :game_day_log
  @spec change_game_day_log(GameDayLog.t()) :: Ecto.Changeset.t()
  @spec change_game_day_log(GameDayLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_game_day_log(game_day_log, attrs \\ %{}), to: GameDayLogLib

  # GameWeekLogs
  alias Angen.Logging.{GameWeekLog, GameWeekLogLib, GameWeekLogQueries}

  @doc false
  @spec game_week_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate game_week_log_query(args), to: GameWeekLogQueries

  @doc section: :game_week_log
  @spec list_game_week_logs(Teiserver.query_args()) :: [GameWeekLog.t()]
  defdelegate list_game_week_logs(args), to: GameWeekLogLib

  @doc section: :game_week_log
  @spec get_game_week_log!(Date.t()) :: GameWeekLog.t()
  @spec get_game_week_log!(Date.t(), Teiserver.query_args()) :: GameWeekLog.t()
  defdelegate get_game_week_log!(date, query_args \\ []), to: GameWeekLogLib

  @doc section: :game_week_log
  @spec get_game_week_log(Date.t()) :: GameWeekLog.t() | nil
  @spec get_game_week_log(Date.t(), Teiserver.query_args()) :: GameWeekLog.t() | nil
  defdelegate get_game_week_log(date, query_args \\ []), to: GameWeekLogLib

  @doc section: :game_week_log
  @spec create_game_week_log(map) :: {:ok, GameWeekLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_game_week_log(attrs), to: GameWeekLogLib

  @doc section: :game_week_log
  @spec update_game_week_log(GameWeekLog, map) ::
          {:ok, GameWeekLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_game_week_log(game_week_log, attrs), to: GameWeekLogLib

  @doc section: :game_week_log
  @spec delete_game_week_log(GameWeekLog.t()) ::
          {:ok, GameWeekLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_game_week_log(game_week_log), to: GameWeekLogLib

  @doc section: :game_week_log
  @spec change_game_week_log(GameWeekLog.t()) :: Ecto.Changeset.t()
  @spec change_game_week_log(GameWeekLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_game_week_log(game_week_log, attrs \\ %{}), to: GameWeekLogLib

  # GameMonthLogs
  alias Angen.Logging.{GameMonthLog, GameMonthLogLib, GameMonthLogQueries}

  @doc false
  @spec game_month_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate game_month_log_query(args), to: GameMonthLogQueries

  @doc section: :game_month_log
  @spec list_game_month_logs(Teiserver.query_args()) :: [GameMonthLog.t()]
  defdelegate list_game_month_logs(args), to: GameMonthLogLib

  @doc section: :game_month_log
  @spec get_game_month_log!(Date.t()) :: GameMonthLog.t()
  @spec get_game_month_log!(Date.t(), Teiserver.query_args()) :: GameMonthLog.t()
  defdelegate get_game_month_log!(date, query_args \\ []), to: GameMonthLogLib

  @doc section: :game_month_log
  @spec get_game_month_log(Date.t()) :: GameMonthLog.t() | nil
  @spec get_game_month_log(Date.t(), Teiserver.query_args()) :: GameMonthLog.t() | nil
  defdelegate get_game_month_log(date, query_args \\ []), to: GameMonthLogLib

  @doc section: :game_month_log
  @spec create_game_month_log(map) :: {:ok, GameMonthLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_game_month_log(attrs), to: GameMonthLogLib

  @doc section: :game_month_log
  @spec update_game_month_log(GameMonthLog, map) ::
          {:ok, GameMonthLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_game_month_log(game_month_log, attrs), to: GameMonthLogLib

  @doc section: :game_month_log
  @spec delete_game_month_log(GameMonthLog.t()) ::
          {:ok, GameMonthLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_game_month_log(game_month_log), to: GameMonthLogLib

  @doc section: :game_month_log
  @spec change_game_month_log(GameMonthLog.t()) :: Ecto.Changeset.t()
  @spec change_game_month_log(GameMonthLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_game_month_log(game_month_log, attrs \\ %{}), to: GameMonthLogLib

  # GameQuarterLogs
  alias Angen.Logging.{GameQuarterLog, GameQuarterLogLib, GameQuarterLogQueries}

  @doc false
  @spec game_quarter_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate game_quarter_log_query(args), to: GameQuarterLogQueries

  @doc section: :game_quarter_log
  @spec list_game_quarter_logs(Teiserver.query_args()) :: [GameQuarterLog.t()]
  defdelegate list_game_quarter_logs(args), to: GameQuarterLogLib

  @doc section: :game_quarter_log
  @spec get_game_quarter_log!(Date.t()) :: GameQuarterLog.t()
  @spec get_game_quarter_log!(Date.t(), Teiserver.query_args()) :: GameQuarterLog.t()
  defdelegate get_game_quarter_log!(date, query_args \\ []), to: GameQuarterLogLib

  @doc section: :game_quarter_log
  @spec get_game_quarter_log(Date.t()) :: GameQuarterLog.t() | nil
  @spec get_game_quarter_log(Date.t(), Teiserver.query_args()) :: GameQuarterLog.t() | nil
  defdelegate get_game_quarter_log(date, query_args \\ []), to: GameQuarterLogLib

  @doc section: :game_quarter_log
  @spec create_game_quarter_log(map) :: {:ok, GameQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_game_quarter_log(attrs), to: GameQuarterLogLib

  @doc section: :game_quarter_log
  @spec update_game_quarter_log(GameQuarterLog, map) ::
          {:ok, GameQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_game_quarter_log(game_quarter_log, attrs), to: GameQuarterLogLib

  @doc section: :game_quarter_log
  @spec delete_game_quarter_log(GameQuarterLog.t()) ::
          {:ok, GameQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_game_quarter_log(game_quarter_log), to: GameQuarterLogLib

  @doc section: :game_quarter_log
  @spec change_game_quarter_log(GameQuarterLog.t()) :: Ecto.Changeset.t()
  @spec change_game_quarter_log(GameQuarterLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_game_quarter_log(game_quarter_log, attrs \\ %{}), to: GameQuarterLogLib

  # GameYearLogs
  alias Angen.Logging.{GameYearLog, GameYearLogLib, GameYearLogQueries}

  @doc false
  @spec game_year_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate game_year_log_query(args), to: GameYearLogQueries

  @doc section: :game_year_log
  @spec list_game_year_logs(Teiserver.query_args()) :: [GameYearLog.t()]
  defdelegate list_game_year_logs(args), to: GameYearLogLib

  @doc section: :game_year_log
  @spec get_game_year_log!(Date.t()) :: GameYearLog.t()
  @spec get_game_year_log!(Date.t(), Teiserver.query_args()) :: GameYearLog.t()
  defdelegate get_game_year_log!(date, query_args \\ []), to: GameYearLogLib

  @doc section: :game_year_log
  @spec get_game_year_log(Date.t()) :: GameYearLog.t() | nil
  @spec get_game_year_log(Date.t(), Teiserver.query_args()) :: GameYearLog.t() | nil
  defdelegate get_game_year_log(date, query_args \\ []), to: GameYearLogLib

  @doc section: :game_year_log
  @spec create_game_year_log(map) :: {:ok, GameYearLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_game_year_log(attrs), to: GameYearLogLib

  @doc section: :game_year_log
  @spec update_game_year_log(GameYearLog, map) ::
          {:ok, GameYearLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_game_year_log(game_year_log, attrs), to: GameYearLogLib

  @doc section: :game_year_log
  @spec delete_game_year_log(GameYearLog.t()) ::
          {:ok, GameYearLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_game_year_log(game_year_log), to: GameYearLogLib

  @doc section: :game_year_log
  @spec change_game_year_log(GameYearLog.t()) :: Ecto.Changeset.t()
  @spec change_game_year_log(GameYearLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_game_year_log(game_year_log, attrs \\ %{}), to: GameYearLogLib

  # ServerMinuteLogs
  alias Angen.Logging.{ServerMinuteLog, ServerMinuteLogLib, ServerMinuteLogQueries}

  @doc false
  @spec server_minute_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_minute_log_query(args), to: ServerMinuteLogQueries

  @doc section: :server_minute_log
  @spec list_server_minute_logs(Teiserver.query_args()) :: [ServerMinuteLog.t()]
  defdelegate list_server_minute_logs(args), to: ServerMinuteLogLib

  @doc section: :server_minute_log
  @spec get_server_minute_log(DateTime.t(), String.t() | [String.t()], Teiserver.query_args()) ::
          ServerMinuteLog.t() | nil
  defdelegate get_server_minute_log(timestamp, node, query_args \\ []), to: ServerMinuteLogLib

  @doc section: :server_minute_log
  @spec get_first_server_minute_datetime() :: DateTime.t() | nil
  defdelegate get_first_server_minute_datetime(), to: ServerMinuteLogLib

  @doc section: :server_minute_log
  @spec create_server_minute_log(map) :: {:ok, ServerMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_minute_log(attrs), to: ServerMinuteLogLib

  @doc section: :server_minute_log
  @spec update_server_minute_log(ServerMinuteLog, map) ::
          {:ok, ServerMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_minute_log(server_minute_log, attrs), to: ServerMinuteLogLib

  @doc section: :server_minute_log
  @spec delete_server_minute_log(ServerMinuteLog.t()) ::
          {:ok, ServerMinuteLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_minute_log(server_minute_log), to: ServerMinuteLogLib

  @doc section: :server_minute_log
  @spec change_server_minute_log(ServerMinuteLog.t()) :: Ecto.Changeset.t()
  @spec change_server_minute_log(ServerMinuteLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_minute_log(server_minute_log, attrs \\ %{}), to: ServerMinuteLogLib

  # ServerDayLogs
  alias Angen.Logging.{ServerDayLog, ServerDayLogLib, ServerDayLogQueries}

  @doc false
  @spec server_day_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_day_log_query(args), to: ServerDayLogQueries

  @doc section: :server_day_log
  @spec list_server_day_logs(Teiserver.query_args()) :: [ServerDayLog.t()]
  defdelegate list_server_day_logs(args), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec get_server_day_log!(Date.t(), Teiserver.query_args()) :: ServerDayLog.t()
  defdelegate get_server_day_log!(date, query_args \\ []), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec get_last_server_day_log_date() :: DateTime.t() | nil
  defdelegate get_last_server_day_log_date(), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec get_server_day_log(Date.t()) :: ServerDayLog.t() | nil
  @spec get_server_day_log(Date.t(), Teiserver.query_args()) :: ServerDayLog.t() | nil
  defdelegate get_server_day_log(date, query_args \\ []), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec create_server_day_log(map) :: {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_day_log(attrs), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec update_server_day_log(ServerDayLog, map) ::
          {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_day_log(server_day_log, attrs), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec delete_server_day_log(ServerDayLog.t()) ::
          {:ok, ServerDayLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_day_log(server_day_log), to: ServerDayLogLib

  @doc section: :server_day_log
  @spec change_server_day_log(ServerDayLog.t()) :: Ecto.Changeset.t()
  @spec change_server_day_log(ServerDayLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_day_log(server_day_log, attrs \\ %{}), to: ServerDayLogLib

  # ServerWeekLogs
  alias Angen.Logging.{ServerWeekLog, ServerWeekLogLib, ServerWeekLogQueries}

  @doc false
  @spec server_week_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_week_log_query(args), to: ServerWeekLogQueries

  @doc section: :server_week_log
  @spec list_server_week_logs(Teiserver.query_args()) :: [ServerWeekLog.t()]
  defdelegate list_server_week_logs(args), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec get_server_week_log!(Date.t()) :: ServerWeekLog.t()
  @spec get_server_week_log!(Date.t(), Teiserver.query_args()) :: ServerWeekLog.t()
  defdelegate get_server_week_log!(date, query_args \\ []), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec get_last_server_week_log_date() :: DateTime.t() | nil
  defdelegate get_last_server_week_log_date(), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec get_server_week_log(Date.t()) :: ServerWeekLog.t() | nil
  @spec get_server_week_log(Date.t(), Teiserver.query_args()) :: ServerWeekLog.t() | nil
  defdelegate get_server_week_log(date, query_args \\ []), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec create_server_week_log(map) :: {:ok, ServerWeekLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_week_log(attrs), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec update_server_week_log(ServerWeekLog, map) ::
          {:ok, ServerWeekLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_week_log(server_week_log, attrs), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec delete_server_week_log(ServerWeekLog.t()) ::
          {:ok, ServerWeekLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_week_log(server_week_log), to: ServerWeekLogLib

  @doc section: :server_week_log
  @spec change_server_week_log(ServerWeekLog.t()) :: Ecto.Changeset.t()
  @spec change_server_week_log(ServerWeekLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_week_log(server_week_log, attrs \\ %{}), to: ServerWeekLogLib

  # ServerMonthLogs
  alias Angen.Logging.{ServerMonthLog, ServerMonthLogLib, ServerMonthLogQueries}

  @doc false
  @spec server_month_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_month_log_query(args), to: ServerMonthLogQueries

  @doc section: :server_month_log
  @spec list_server_month_logs(Teiserver.query_args()) :: [ServerMonthLog.t()]
  defdelegate list_server_month_logs(args), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec get_server_month_log!(Date.t()) :: ServerMonthLog.t()
  @spec get_server_month_log!(Date.t(), Teiserver.query_args()) :: ServerMonthLog.t()
  defdelegate get_server_month_log!(date, query_args \\ []), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec get_server_month_log(Date.t()) :: ServerMonthLog.t() | nil
  @spec get_server_month_log(Date.t(), Teiserver.query_args()) :: ServerMonthLog.t() | nil
  defdelegate get_server_month_log(date, query_args \\ []), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec get_last_server_month_log_date() :: DateTime.t() | nil
  defdelegate get_last_server_month_log_date(), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec create_server_month_log(map) :: {:ok, ServerMonthLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_month_log(attrs), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec update_server_month_log(ServerMonthLog, map) ::
          {:ok, ServerMonthLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_month_log(server_month_log, attrs), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec delete_server_month_log(ServerMonthLog.t()) ::
          {:ok, ServerMonthLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_month_log(server_month_log), to: ServerMonthLogLib

  @doc section: :server_month_log
  @spec change_server_month_log(ServerMonthLog.t()) :: Ecto.Changeset.t()
  @spec change_server_month_log(ServerMonthLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_month_log(server_month_log, attrs \\ %{}), to: ServerMonthLogLib

  # ServerQuarterLogs
  alias Angen.Logging.{ServerQuarterLog, ServerQuarterLogLib, ServerQuarterLogQueries}

  @doc false
  @spec server_quarter_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_quarter_log_query(args), to: ServerQuarterLogQueries

  @doc section: :server_quarter_log
  @spec list_server_quarter_logs(Teiserver.query_args()) :: [ServerQuarterLog.t()]
  defdelegate list_server_quarter_logs(args), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec get_server_quarter_log!(Date.t()) :: ServerQuarterLog.t()
  @spec get_server_quarter_log!(Date.t(), Teiserver.query_args()) :: ServerQuarterLog.t()
  defdelegate get_server_quarter_log!(date, query_args \\ []), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec get_server_quarter_log(Date.t()) :: ServerQuarterLog.t() | nil
  @spec get_server_quarter_log(Date.t(), Teiserver.query_args()) :: ServerQuarterLog.t() | nil
  defdelegate get_server_quarter_log(date, query_args \\ []), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec get_last_server_quarter_log_date() :: DateTime.t() | nil
  defdelegate get_last_server_quarter_log_date(), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec create_server_quarter_log(map) ::
          {:ok, ServerQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_quarter_log(attrs), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec update_server_quarter_log(ServerQuarterLog, map) ::
          {:ok, ServerQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_quarter_log(server_quarter_log, attrs), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec delete_server_quarter_log(ServerQuarterLog.t()) ::
          {:ok, ServerQuarterLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_quarter_log(server_quarter_log), to: ServerQuarterLogLib

  @doc section: :server_quarter_log
  @spec change_server_quarter_log(ServerQuarterLog.t()) :: Ecto.Changeset.t()
  @spec change_server_quarter_log(ServerQuarterLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_quarter_log(server_quarter_log, attrs \\ %{}), to: ServerQuarterLogLib

  # ServerYearLogs
  alias Angen.Logging.{ServerYearLog, ServerYearLogLib, ServerYearLogQueries}

  @doc false
  @spec server_year_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_year_log_query(args), to: ServerYearLogQueries

  @doc section: :server_year_log
  @spec list_server_year_logs(Teiserver.query_args()) :: [ServerYearLog.t()]
  defdelegate list_server_year_logs(args), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec get_server_year_log!(Date.t()) :: ServerYearLog.t()
  @spec get_server_year_log!(Date.t(), Teiserver.query_args()) :: ServerYearLog.t()
  defdelegate get_server_year_log!(date, query_args \\ []), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec get_server_year_log(Date.t()) :: ServerYearLog.t() | nil
  @spec get_server_year_log(Date.t(), Teiserver.query_args()) :: ServerYearLog.t() | nil
  defdelegate get_server_year_log(date, query_args \\ []), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec get_last_server_year_log_date() :: DateTime.t() | nil
  defdelegate get_last_server_year_log_date(), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec create_server_year_log(map) :: {:ok, ServerYearLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_year_log(attrs), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec update_server_year_log(ServerYearLog, map) ::
          {:ok, ServerYearLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_year_log(server_year_log, attrs), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec delete_server_year_log(ServerYearLog.t()) ::
          {:ok, ServerYearLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_year_log(server_year_log), to: ServerYearLogLib

  @doc section: :server_year_log
  @spec change_server_year_log(ServerYearLog.t()) :: Ecto.Changeset.t()
  @spec change_server_year_log(ServerYearLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_year_log(server_year_log, attrs \\ %{}), to: ServerYearLogLib
end
