import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/angen start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :angen, AngenWeb.Endpoint, server: true
end

if config_env() == :prod do
  System.get_env("DATABASE_USERNAME") || raise "environment variable DATABASE_USERNAME is missing"

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :angen, Angen.Repo,
    # ssl: true,
    username: System.get_env("DATABASE_USERNAME"),
    password: System.get_env("DATABASE_PASSWORD"),
    hostname: System.get_env("DATABASE_HOSTNAME"),
    database: System.get_env("DATABASE_DB_NAME"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  domain_name = System.get_env("DOMAIN_NAME") || raise "DOMAIN_NAME not set"

  config :angen, AngenWeb.Endpoint,
    url: [
      host: host,
      scheme: "https"
    ],
    # http: [
    #   # Enable IPv6 and bind on all interfaces.
    #   # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
    #   # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
    #   # for details about using IPv6 vs IPv4 and loopback vs public addresses.
    #   ip: {0, 0, 0, 0, 0, 0, 0, 0},
    #   port: port
    # ],
    https: [
      port: String.to_integer(System.get_env("HTTPS_PORT") || "8888"),
      keyfile: "/etc/letsencrypt/live/#{domain_name}/privkey.pem",
      certfile: "/etc/letsencrypt/live/#{domain_name}/cert.pem",
      cacertfile: "/etc/letsencrypt/live/#{domain_name}/fullchain.pem",
      versions: [:"tlsv1.2"],
      dhfile: ~c"/var/www/tls/dh-params.pem",
      ciphers: [
        ~c"ECDHE-ECDSA-AES256-GCM-SHA384",
        ~c"ECDHE-RSA-AES256-GCM-SHA384",
        ~c"ECDHE-ECDSA-AES256-SHA384",
        ~c"ECDHE-RSA-AES256-SHA384",
        ~c"ECDHE-ECDSA-DES-CBC3-SHA",
        ~c"ECDH-ECDSA-AES256-GCM-SHA384",
        ~c"ECDH-RSA-AES256-GCM-SHA384",
        ~c"ECDH-ECDSA-AES256-SHA384",
        ~c"ECDH-RSA-AES256-SHA384",
        ~c"DHE-DSS-AES256-GCM-SHA384",
        ~c"DHE-DSS-AES256-SHA256",
        ~c"AES256-GCM-SHA384",
        ~c"AES256-SHA256",
        ~c"ECDHE-ECDSA-AES128-GCM-SHA256",
        ~c"ECDHE-RSA-AES128-GCM-SHA256",
        ~c"ECDHE-ECDSA-AES128-SHA256",
        ~c"ECDHE-RSA-AES128-SHA256",
        ~c"ECDH-ECDSA-AES128-GCM-SHA256",
        ~c"ECDH-RSA-AES128-GCM-SHA256",
        ~c"ECDH-ECDSA-AES128-SHA256",
        ~c"ECDH-RSA-AES128-SHA256",
        ~c"DHE-DSS-AES128-GCM-SHA256",
        ~c"DHE-DSS-AES128-SHA256",
        ~c"AES128-GCM-SHA256",
        ~c"AES128-SHA256",
        ~c"ECDHE-ECDSA-AES256-SHA",
        ~c"ECDHE-RSA-AES256-SHA",
        ~c"DHE-DSS-AES256-SHA",
        ~c"ECDH-ECDSA-AES256-SHA",
        ~c"ECDH-RSA-AES256-SHA",
        ~c"AES256-SHA",
        ~c"ECDHE-ECDSA-AES128-SHA",
        ~c"ECDHE-RSA-AES128-SHA",
        ~c"DHE-DSS-AES128-SHA",
        ~c"ECDH-ECDSA-AES128-SHA",
        ~c"ECDH-RSA-AES128-SHA",
        ~c"AES128-SHA"
      ],
      secure_renegotiate: true,
      reuse_sessions: true,
      honor_cipher_order: true
    ],
    force_ssl: [hsts: true],
    root: ".",
    cache_static_manifest: "priv/static/cache_manifest.json",
    server: true,
    check_origin: ["//#{domain_name}", "//*.#{domain_name}"],
    version: "0.0.1",
    secret_key_base: secret_key_base

  # Teiserver specific to prod
  config :teiserver,
    node_name: System.get_env("NODE_NAME") || hd(String.split(domain_name, "."))

  cert_root = System.get_env("CERT_ROOT") || "/etc/letsencrypt/live/#{domain_name}"

  config :fontawesome,
    free_only: System.get_env("FONTAWESOME_FREE_ONLY", "TRUE") == "TRUE"

  # Angen itself
  config :angen,
    tls_port: String.to_integer(System.get_env("TLS_PORT") || "8201"),
    json_schema_path:
      System.get_env("JSON_SCHEMA_PATH") || "/apps/angen/lib/angen-0.0.1/priv/static/schema",
    certs: [
      keyfile: "#{cert_root}/privkey.pem",
      certfile: "#{cert_root}/cert.pem",
      cacertfile: "#{cert_root}/fullchain.pem"
    ],

    # Website
    site_title: System.get_env("ANGEN_SITE_TITLE", "Angen"),

    # Default configs
    default_site_settings: %{
      allow_user_registration:
        System.get_env("ANGEN_DEFAULT_ALLOW_USER_REGISTRATION", "TRUE") == "TRUE",
      require_tokens_to_persist_ip:
        System.get_env("ANGEN_DEFAULT_REQUIRE_TOKENS_TO_PERSIST_IP", "FALSE") == "TRUE",
      allow_lobby_whisper: System.get_env("ANGEN_DEFAULT_ALLOW_LOBBY_WHISPER", "FALSE") == "TRUE",
      integration_mode: System.get_env("ANGEN_DEFAULT_INTEGRATION_MODE", "FALSE") == "TRUE"
    },
    default_user_settings: %{}
end
