# Config
These are values configured at startup (for Elixir devs, this just goes over the runtime.exs process), the logic flow is:
- When releasing the values are copied from `/apps/angen.vars` into `/apps/angen/releases/0.0.1/env.sh`
- At startup Angen reads from this file and sets those as environment variables
- The environment variables are converted into application variables through [runtime.exs](/config/runtime.exs); in particular on the blocks starting with `config :angen,` and `config :teiserver,`
- When Angen is running these variables are used

The values are intended to be set once and not need changing again, they are also designed to only need to be accessed by devops/sysadmin users. Game admins/moderators have a set of runtime configs they can access via a live interface and are designed to be changed while the server is still running.

## Changing things on the fly
If for whatever reason you need to change something on the fly you can do so by accessing the remote shell of Angen and using the following commands.

```elixir
# Get a value
Application.get_env(:angen, :var_name)

# Put a value
Application.put_env(:angen, :var_name, value)
```

# Options - Runtime
The following options can be changed on the fly using the above snippet.

## `CERT_ROOT`
The root path for your certificate. By default it will point to `/etc/letsencrypt/live/#{domain_name}`.

## `JSON_SCHEMA_PATH`
The path used to store the protocol schema which is bundled as part of the release process. If you want to place the schema somewhere else then you will want to update this variable and also use the remote shell to run:
```elixir
Angen.Helpers.JsonSchemaHelper.load()
```

Defaults to `/apps/angen/lib/angen-0.0.1/priv/static/schema`

# Options - Startup only
The following options are used at startup time only, changing them on the fly will almost certainly not work correctly (and in some cases could break things).

## `TLS_PORT`
The port used to accept TLS connections. Defaults to `8201`.
