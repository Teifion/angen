import Config

config :angen,
  dev_routes: true,
  tls_port: 8201,
  certs: [
    keyfile: "priv/certs/localhost.key",
    certfile: "priv/certs/localhost.crt",
    cacertfile: "priv/certs/localhost.crt"
  ],
  integration_mode: true,
  enfys_mode: true,
  enfys_key: "enfys"

# Configure your database
config :angen, Angen.Repo,
  username: "angen_dev",
  password: "postgres",
  hostname: "localhost",
  database: "angen_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :angen, AngenWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "PizUD3vNiMuQQcJOywNlaLYZVD5h3ir3SG3HVq62/4u6yVG/qPewwRbFapOCZkxT",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    dark_sass: {
      DartSass,
      :install_and_run,
      [:dark, ~w(--embed-source-map --source-map-urls=absolute --watch)]
    },
    light_sass: {
      DartSass,
      :install_and_run,
      [:light, ~w(--embed-source-map --source-map-urls=absolute --watch)]
    }
  ]

# Watch static and templates for browser reloading.
config :angen, AngenWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/angen_web/(controllers|live|components|live_components)/.*(ex|heex)$"
    ]
  ]

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Comment the below block to allow background jobs to happen in dev
config :angen, Oban,
  queues: false,
  crontab: false

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n",
  truncate: :infinity

try do
  import_config "dev.secret.exs"
rescue
  _ in File.Error ->
    nil

  error ->
    reraise error, __STACKTRACE__
end
