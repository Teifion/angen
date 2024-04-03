# Authentication
The login flow for the Angen protocol is:
- Connect to TCP socket
- If no token locally
  - Get token via `auth/get_token`
  - Store token locally
- Use token for `auth/login`

### Why use tokens
By using tokens instead of passwords there is no need to keep the user password on the computer meaning it cannot be stolen. If a token is stolen it can of course be used but the password itself is not compromised and the token can be revoked.

# Configuration
### `:require_tokens_to_persist_ip`
When a token is created the IP used is tracked. If this option is enabled then the IP used to login via the token must match the token stored in the database. When enabled this can help prevent token theft but at the cost of needing users to re-acquire a token every time they change IP address.

This setting can be changed as a ServerSetting.

# Protocol
## `auth/get_token`
[Request](/priv/static/schema/commands/auth/get_token_command.json) - [Response](/priv/static/schema/messages/auth/token_message.json)

Start by making an `auth/get_token` request like so:
```json
{
  "name": "auth/get_token",
  "command": {
    "name": "teifion",
    "password": "password1",
    "user_agent": "application name"
  }
}
```

This will return you a token like so:
```json
{
  "name": "auth/token",
  "message": {
    "token": {
      "user_id": "1a29545c-f2b0-4b70-9f35-d4104471f3aa",
      "identifier_code": "dd0PBc9vPibBozlfDh0RUekd34o......FLxaPIpFs+HSIe79",
      "renewal_code": "ZdyzlENHgAwZU1LaPkDwM.......bTMgobp7Wlbeh0sSWN1pKXZ",
      "expires_at": "2024-03-05T00:06:40.888869Z"
    }
  }
}
```

You will need to use the `identifier_code` to login and the `renewal_code` to renew the token when it is due to expire.

## `auth/login`
[Request](/priv/static/schema/commands/auth/login_command.json) - [Response](/priv/static/schema/messages/auth/logged_in_message.json)

To login you will need to send an `auth/login` request:
```json
{
  "name": "auth/login",
  "command": {
    "identifier_code": "dd0PBc9vPibBozlfDh0RUekd34o......FLxaPIpFs+HSIe79",
    "user_agent": "application name"
  }
}
```

If successful you will get a response of:
```json
{
  "name": "auth/logged_in",
  "message": {
    "user": {
      "id": "1a29545c-f2b0-4b70-9f35-d4104471f3aa",
      "name": "teifion"
    }
  }
}
```

## `auth/renew`
[Request](/priv/static/schema/commands/auth/renew_command.json) - [Response](/priv/static/schema/messages/auth/token_message.json)

Renews the token; if successful you will receive a new token similar to `auth/get_token` and the existing token will expire early. You do not need to be authenticated to perform this operation and any existing connection will not be affected.

```json
{
  "name": "auth/renew",
  "command": {
    "identifier_code": "dd0PBc9vPibBozlfDh0RUekd34o......FLxaPIpFs+HSIe79",
    "renewal_code": "ZdyzlENHgAwZU1LaPkDwM.......bTMgobp7Wlbeh0sSWN1pKXZ",
  }
}
```

```json
{
  "name": "auth/token",
  "message": {
    "token": {
      "user_id": "1a29545c-f2b0-4b70-9f35-d4104471f3aa",
      "identifier_code": "UFlW1tuqy+u9sz2uhxM8kI1m01l90SOt1zjNGYi",
      "renewal_code": "KPdk2rOBHwRu0a3lLUeB5/sW4v1E9F7tHMJUcqwWa",
      "expires_at": "2024-04-05T00:06:40.888869Z"
    }
  }
}
```