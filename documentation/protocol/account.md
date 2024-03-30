# Account
Everything related to account management.

## Request `account/register`
[Request](/priv/static/schema/commands/account/register_command.json) - [Response](/priv/static/schema/messages/account/registered_message.json)

Registration is the process of creating new accounts. It can be enabled/disabled with a system setting. To register an account you can use:
```json
{
  "name": "account/register",
  "command": {
    "name": "Teifion",
    "password": "password1",
    "email": "email@email"
  }
}
```

If successful you should receive something like:

```json
{
  "name": "account/registered",
  "message": {
    "user": {
      "id": "3c914d97-e055-4f39-9ae1-1b5276c67bcb",
      "name": "Teifion"
    }
  }
}
```

At that stage you can make use of the [authentication flow](authentication.md) to login.

## TODO: `account/reset_password`
Start the reset-password process, revokes tokens.

## TODO: `account/verify`
Command to verify the account in some way

## `account/user_query`
[Request](/priv/static/schema/commands/account/user_query_command.json) - [Response](/priv/static/schema/messages/account/user_list_message.json)

Retrieves information about one or more users by their IDs or name:
```json
{
  "name": "account/user_query",
  "command": {
    "filters": {
      "id": [
        "f627ed52-54ce-4074-ba14-03f283f025c6",
        "a9d3dbe8-9376-4b0b-90ce-435ea3028005",
        "f301e9b7-53dd-4df7-bbcb-194ff9aad4e2"
      ],
      "name": "name-here"
    }
  }
}
```

Found users are returned as such. Any IDs which do not link to a user are simply not included. As long as the schema is correctly structured a "failure" response will just be an empty list of users.

```json
{
  "name": "account/user_list",
  "message": {
    "users": [
      {
        "id": "f627ed52-54ce-4074-ba14-03f283f025c6",
        "name": "Teifion"
      },
      {
        "id": "f627ed52-54ce-4074-ba14-03f283f025c6",
        "name": "Nacho"
      },
      {
        "id": "f627ed52-54ce-4074-ba14-03f283f025c6",
        "name": "Noodle"
      }
    ]
  }
}
```

## `account/update`
[Request](/priv/static/schema/commands/account/update_command.json)

Updates account details.

```json
{
  "name": "account/update",
  "command": {
    "email": "new-email@email",
    "name": "new-name"
  }
}
```

## `account/change_password`
[Request](/priv/static/schema/commands/account/change_password_command.json)

Updates the password for the account. If successful all user connections (including this one) will be disconnected; similar to the `account/revoke_tokens`.

```json
{
  "name": "account/change_password",
  "command": {
    "existing_password": "password1",
    "new_password": "password2"
  }
}
```


## `account/revoke_tokens`
[Request](/priv/static/schema/commands/account/revoke_tokens_command.json)

Invalidates all tokens for this account; any existing connections (including the one currently connected) will be disconnected. Due to timing issues with the destruction of the connection it is possible you will receive a success message.

```json
{
  "name": "account/revoke_tokens",
  "command": {}
}
```

## TODO: `account/forgetme`
Flag the account for GDPR deletion in 24 hours (to allow undoing of this command)

## TODO: `account/cancel_forgetme`
Cancels GDPR deletion.

