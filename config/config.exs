# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :angen,
  persist_telemetry_events: true,
  ecto_repos: [Angen.Repo],
  site_title: "Angen DEV",
  json_schema_path: "priv/static/schema"

# Configures the endpoint
config :angen, AngenWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AngenWeb.ErrorHTML, json: AngenWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Angen.PubSub,
  live_view: [signing_salt: "/VE7+Rve"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :angen, Angen.Mailer, adapter: Swoosh.Adapters.Local

config :teiserver,
  repo: Angen.Repo,
  fn_lobby_name_acceptor: &Angen.Helpers.OverrideHelper.lobby_name_acceptor/1,
  fn_user_name_acceptor: &Angen.Helpers.OverrideHelper.user_name_acceptor/1

config :db_cluster,
  repo: Angen.Repo

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.61.0",
  light: [
    args: ~w(scss/light.scss ../priv/static/assets/light.css),
    cd: Path.expand("../assets", __DIR__)
  ],
  dark: [
    args: ~w(scss/dark.scss ../priv/static/assets/dark.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_json_schema,
       :remote_schema_resolver,
       {Angen.Helpers.JsonSchemaHelper, :resolve_schema}

config :angen, Oban,
  repo: Angen.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 3600},
    {Oban.Plugins.Cron,
     crontab: [
      # Every minute
      {"* * * * *", Angen.Logging.TriggerPersistServerMinuteTask},

      # 2am, to help prevent any issues when clocks move an hour
      {"1 2 * * *", Angen.Logging.PersistServerDayTask},
      {"3 2 * * *", Angen.Logging.PersistServerWeekTask},
      {"5 2 * * *", Angen.Logging.PersistServerMonthTask},
      {"7 2 * * *", Angen.Logging.PersistServerQuarterTask},
      {"9 2 * * *", Angen.Logging.PersistServerYearTask},

      # Now the same but for matches
      {"1 2 * * *", Angen.Logging.PersistGameDayTask},
      {"3 2 * * *", Angen.Logging.PersistGameWeekTask},
      {"5 2 * * *", Angen.Logging.PersistGameMonthTask},
      {"7 2 * * *", Angen.Logging.PersistGameQuarterTask},
      {"9 2 * * *", Angen.Logging.PersistGameYearTask}
     ]}
  ],
  queues: [logging: 1, cleanup: 1, teiserver: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
