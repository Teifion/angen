import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :angen, Angen.Repo,
  username: "angen_test",
  password: "postgres",
  hostname: "localhost",
  database: "angen_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :teiserver,
  teiserver_clustering: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :angen, AngenWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "EaISGtmP6JQp0nL8nkzR0dxIlwCFr2oTm04hMrIt1fSZXREHevHPOeHpoJvwicX0",
  server: false

# In test we don't send emails.
config :angen, Angen.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :angen, Oban, testing: :manual

config :angen,
  dev_routes: true,
  test_mode: true,
  tls_port: 9201,
  certs: [
    keyfile: "priv/certs/localhost.key",
    certfile: "priv/certs/localhost.crt",
    cacertfile: "priv/certs/localhost.crt"
  ]

# This makes anything in our tests involving user passwords (creating or logging in) much faster
config :argon2_elixir, t_cost: 1, m_cost: 8
