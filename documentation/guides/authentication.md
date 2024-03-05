# Configs

### `:require_tokens_to_persist_ip`
When a token is created the IP used is tracked. If this option is enabled then the IP used to login via the token must match the token stored in the database. When enabled this can help prevent token theft but at the cost of needing users to re-acquire a token every time they change IP address.

### Get token
Start by making an `auth/get_token` request like so:
```json
{
  "name": "auth/get_token",
  "command": {
    "username": "teifion",
    "password": "password1"
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

### Login with token
To login you will need to send an `auth/login` request:
```json
{
  "name": "auth/login",
  "command": {
    "identifier_code": "dd0PBc9vPibBozlfDh0RUekd34o......FLxaPIpFs+HSIe79"
  }
}
```

If successful you will get a response of:
```json
%{
  "name": "auth/logged_in",
  "message": {
    "user": {
      "id": "1a29545c-f2b0-4b70-9f35-d4104471f3aa",
      "name": "teifion"
    }
  }
}
```

### Why use tokens
By using tokens instead of passwords there is no need to keep the user password on the computer meaning it cannot be stolen. If a token is stolen it can of course be used but the password itself is not compromised and the token can be revoked.

