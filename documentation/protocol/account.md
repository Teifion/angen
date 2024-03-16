# Account
Everything related to account management.

## `account/register`
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

## `account/verify`

## `account/whois`