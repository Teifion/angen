# Event commands
Used for [telemetry events](/documentation/guides/admin/telemetry_events.md).

## Anonymous
[Request](/priv/static/schema/commands/events/anonymous_command.json)

Registers the happening of an event anonymously. If successful returns a standard success response.
```json
{
  "name": "events/anonymous",
  "command": {
    "event": "some event",
    "hash_id": "876ae68d-ab67-4f9f-bc5e-330060cb3e42"
  }
}
```

Extra detail is optional
```json
{
  "name": "events/anonymous",
  "command": {
    "event": "some event",
    "hash_id": "876ae68d-ab67-4f9f-bc5e-330060cb3e42",
    "details": {
      "key1": "value1",
      "key2": 123,
      "key3": [1, 2, 4]
    }
  }
}
```

Error codes:
```
"Error storing event"
```


## Client
[Request](/priv/static/schema/commands/events/client_command.json)

Registers the happening of an event linked to this account. If successful returns a standard success response.
```json
{
  "name": "events/client",
  "command": {
    "event": "some event"
  }
}
```

Extra detail is optional
```json
{
  "name": "events/client",
  "command": {
    "event": "some event",
    "details": {
      "key1": "value1",
      "key2": 123,
      "key3": [1, 2, 4]
    }
  }
}
```

Error codes:
```
"Must be logged in"
"Error storing event"
```


## Match
[Request](/priv/static/schema/commands/events/match_command.json)

Registers the happening of an event within an ongoing match; must be sent while said match is ongoing. If successful returns a standard success response.
```json
{
  "name": "events/match",
  "command": {
    "event": "some event",
    "game_seconds": 123
  }
}
```

Extra detail is optional
```json
{
  "name": "events/match",
  "command": {
    "event": "some event",
    "game_seconds": 123,
    "details": {
      "key1": "value1",
      "key2": 123,
      "key3": [1, 2, 4]
    }
  }
}
```

Error codes:
```
"Must be logged in"
"Must be in an ongoing match"
"Error storing event"
```

## Host match
[Request](/priv/static/schema/commands/events/match_command.json)

Registers the happening of an event within an ongoing match on behalf of a player in said match; must be sent while said match is ongoing and can only be sent by the host of the match in question. If successful returns a standard success response.
```json
{
  "name": "events/host_match",
  "command": {
    "event": "some event",
    "user_id": "507afab9-46ea-4273-a987-a7b095a1b69d",
    "game_seconds": 123
  }
}
```

Extra detail is optional
```json
{
  "name": "events/host_match",
  "command": {
    "event": "some event",
    "user_id": "507afab9-46ea-4273-a987-a7b095a1b69d",
    "game_seconds": 123,
    "details": {
      "key1": "value1",
      "key2": 123,
      "key3": [1, 2, 4]
    }
  }
}
```

Error codes:
```
"Must be logged in"
"Must be in an ongoing match"
"Must be the host of the lobby"
"Error storing event"
```