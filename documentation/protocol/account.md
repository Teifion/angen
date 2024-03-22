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

## `account/reset_password`
Start the reset-password process, revokes tokens.

## `account/verify`
Command to verify the account in some way

## `account/user_query`
[Request](/priv/static/schema/commands/account/user_query_command.json) - [Response](/priv/static/schema/messages/account/user_info_message.json)

Retrieves information about one or more users by their IDs:
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
  "name": "account/registered",
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
Updates account details.

## `account/revoke_tokens`
Invalidates all tokens for this account.

## `account/forgetme`
Flag the account for GDPR deletion in 24 hours (to allow undoing of this command)

## `account/cancel_forgetme`
Cancels GDPR deletion.

