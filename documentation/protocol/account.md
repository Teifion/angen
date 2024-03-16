# Account
Everything related to account management.

## Request `account/register`
[Request](/priv/static/schema/commands/account/register_command.json) - [Response](/priv/static/schema/messages/account/registered_message.json)

Registration is the process of creating new accounts. It can be enabled/disabled with a system setting. To register an account you can use:
```json
{
  "name": "account/register",
  "command": {
    "name": "teifion",
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
      "name": "teifion"
    }
  }
}
```

At that stage you can make use of the [authentication flow](authentication.md) to login.

## `account/reset_password`
Start the reset-password process, revokes tokens.

## `account/verify`
Command to verify the account in some way

## `account/whois`
Returns info about the account you are logged in as.

## `account/update`
Updates account details.

## `account/revoke_tokens`
Invalidates all tokens for this account.

## `account/forgetme`
Flag the account for GDPR deletion in 24 hours (to allow undoing of this command)