# Local setup
This is a guide for developing Angen locally. If you are just deploying Angen then you likely will not need this guide. Angen is a [Phoenix](https://www.phoenixframework.org/) project with a few extra steps. This guide is primarily aimed at those who are new to Elixir/Phoenix.

## Install services
You will need to install:
- [Elixir/Erlang installed](https://elixir-lang.org/install.html).
- [Postresql](https://www.postgresql.org/download).

I prefer using [asdf](https://github.com/asdf-vm/asdf) and have included a `.tool-versions` to enable you to simply `asdf install`.

## Clone repo and pull dependencies
```bash
git clone git@github.com:Teifion/Angen.git
cd angen
mix deps.get && mix deps.compile
```

## Postgres setup
If you want to change the username or password then you will need to update the relevant files in [config](/config).
```bash
sudo su postgres
psql postgres postgres <<EOF
CREATE USER angen_dev WITH PASSWORD 'postgres';
CREATE DATABASE angen_dev;
GRANT ALL PRIVILEGES ON DATABASE angen_dev to angen_dev;
ALTER USER angen_dev WITH SUPERUSER;

CREATE USER angen_test WITH PASSWORD 'postgres';
CREATE DATABASE angen_test;
GRANT ALL PRIVILEGES ON DATABASE angen_test to angen_test;
ALTER USER angen_test WITH SUPERUSER;
EOF
exit
```

## Localhost certs
To run the TLS server locally you will also need to create localhost certificates in `priv/certs` using the following commands

```bash
mkdir -p priv/certs
cd priv/certs
openssl dhparam -out dh-params.pem 2048
openssl req -x509 -out localhost.crt -keyout localhost.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
cd ../..
```

## SASS
We use sass for our css generation and you'll need to run this to get it started.
```bash
mix sass.install
```

## Running it
Standard mode
```bash
mix phx.server
```

Interactive REPL mode
```bash
iex -S mix phx.server
```

If all goes to plan you should be able to access your site locally at [http://localhost:4000/](http://localhost:4000/).

### Libraries you need to get yourself
The site makes liberal use of [FontAwesome](https://fontawesome.com/) so if you are using the site you'll need to download it and do the following
```bash
fontawesome/css/all.css -> priv/static/css/fontawesome.css
fontawesome/webfonts -> priv/static/webfonts
```

## Connecting to the your server locally
```bash
openssl s_client -connect localhost:8201
```

### config/dev.secret.exs
If you want to do things like have a discord bot in development you don't want these details going into git. You can create a file `config/dev.secret.exs` where you can put these config details; the file must act like any other config file though is already ignored by gitignore.

## Creating your admin account
```elixir
Teiserver.Account.create_user(%{
  name: "root",
  email: "root@localhost",
  password: "password",
  groups: ["admin"],
  permissions: ["admin"]
})
```

## Resetting your user password
When running locally it's likely you won't want to connect the server to an email account, as such password resets need to be done a little differently.

Run your server with `iex -S mix phx.server` and then once it has started up use the following code to update your password.

```elixir
user = Teiserver.Account.get_user_by_email("root@localhost")
Teiserver.Account.update_user(user, %{"password" => "your password here"})
```
