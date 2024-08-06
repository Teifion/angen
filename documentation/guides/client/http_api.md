# HTTP API
Angen comes with a HTTP API. By default this API is disabled as it is typically more efficient to make use of the socket protocol. This page contains information on standard http endpoints, those setting up the system will likely want to also look at [../admin/collector_mode.md](admin/collector_mode.md)

# Authentication
### Request token
- Method: `POST`
- URL: `api/request_token`
- Params:
  - `id`: The UUID of the user you want a token for
  - `password`: The password to authenticate the user
  - `user_agent`: The user agent which should be tracked for the token

An `identifier_code` will be returned in the response, it is then placed in future request headers under the `token` key.

Example request
```json
{
  "id": "c52bf5c1-1120-4e38-b807-f274db281ebc",
  "password": "correct battery horse staple",
  "user_agent": "some client"
}
```

Example success
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

### Renew token
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


# Telemetry events
### Simple clientapp event
- Method: `POST`
- URL: `api/events/simple_clientapp`
- Params:
  - `events`: A list of events being created:
    - `name`: The name of the event taking place
    - Optional: `user_id`: The user this is taken place for if not the token bearer

Example request
```json
{
  "events": [
    %{"name": "event type 1"},
    %{"name": "event type 2"},
    %{"name": "event type 1", "user_id": "d9b39e1a-00fe-4b9e-9e99-4dc4e964ceaa"}
  ]
}
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 3
}
```

### Complex clientapp event
- Method: `POST`
- URL: `api/events/complex_clientapp`
- Params:
  - `events`: A list of events being created:
    - `name`: The name of the event taking place
    - `details`: A json object of the data to store for the event
    - Optional: `user_id`: The user this is taken place for if not the token bearer

Example request
```json
{
  "events": [
    %{"name": "event type 1", "details": {"count": 12}},
    %{"name": "event type 2", "details": {"count": 14}},
    %{"name": "event type 1", "user_id": "56dabb7f-0c4a-43d3-9d66-6474aa761fc9", "details": {"count": 9}}
  ]
}
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 3
}
```

