# HTTP API
Angen comes with a HTTP API. By default this API is disabled as it is typically more efficient to make use of the socket protocol. This page contains information on standard http endpoints, those setting up the system will likely want to also look at [../admin/collector_mode.md](admin/collector_mode.md).

There is also a [Bruno](https://www.usebruno.com/) collection placed in [/bru](/bru) of the Angen repo. You will need to create a `.env` file once you have token data. An example `.env.sample` file is present for your convenience.

# Authentication
### Request token
[Example bru](/bru/Auth/Request_token.bru)
- Method: `POST`
- URL: `api/request_token?id=SOME_UUID&password=PASSWORD&user_agent=AGENT_NAME`
- URL: `api/request_token?email=SOME@EMAIL&password=PASSWORD&user_agent=AGENT_NAME`
- Params:
  - `id`: The UUID of the user you want a token for, this is the preferred method but you can use the email if needed
  - `email`: The email of the user you want a token for, you can use this instead of the ID
  - `password`: The password to authenticate the user
  - `user_agent`: The user agent which should be tracked for the token

An `identifier_code` will be returned in the response, it is then placed in future request auth headers bearer token.

Example request params
```json
{
  "id": "c52bf5c1-1120-4e38-b807-f274db281ebc",
  "password": "correct battery horse staple",
  "user_agent": "some client"
}

{
  "email": "my@email",
  "password": "correct battery horse staple",
  "user_agent": "some client"
}
```

Example success response
```json
{
  "result": "success",
  "token": {
    "expires_at": "2024-09-06T14:31:51Z",
    "identifier_code": "really-long-string",
    "renewal_code": "another-really-long-string",
    "user_id": "c52bf5c1-1120-4e38-b807-f274db281ebc"
  }
}
```

### Ping
[Example bru](/bru/Auth/ping.bru)
Useful to test authentication without changing any data.

- Method: `GET`
- URL: `api/ping`

Example response
```json
{
  "result": "Pong"
}
```


### Renew token
[Example bru](/bru/Auth/Renew_token.bru)
- Method: `POST`
- URL: `api/renew_token`
- Params:
  - `renewal_code`: The renewal code for the token you're currently using

Renewing a token will delete the old token and return a new token similar in nature to the `api/request_token` endpoint

Example request
```json
{
  "renewal_code": "another-really-long-string"
}
```

Example success
```json
{
  "result": "success",
  "token": {
    "expires_at": "2024-09-06T14:31:51Z",
    "identifier_code": "really-long-string2",
    "renewal_code": "yet-another-really-long-string",
    "user_id": "063cce9e-dbff-4bd7-8bb3-aa163a49a935"
  }
}
```


