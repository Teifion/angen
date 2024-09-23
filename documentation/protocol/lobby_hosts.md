# Lobby hosts
For hosting of lobbies

## `lobby/open`
[Request](/priv/static/schema/commands/lobby/open_command.json) - [Response](/priv/static/schema/messages/lobby/opened_message.json)

Opens a new lobby; new lobbies have very few details and you are expected to send a `lobby/change` message to set the relevant values.
```json
{
  "name": "lobby/open",
  "command": {
    "name": "My super amazing lobby"
  }
}
```

If successful you will get a `lobby/opened` response:
```json
{
  "name": "lobby/opened",
  "message": {
    "lobby_id": "84b7e163-4086-49f5-a9e4-f33a1a9f41cd"
  }
}
```

## `lobby/close`
[Request](/priv/static/schema/commands/lobby/close_command.json) - [Response](/priv/static/schema/messages/lobby/closed_message.json)

Closes the lobby you are currently hosting; all members are removed.
```json
{
  "name": "lobby/close",
  "command": {}
}
```

## `lobby/change`
[Request](/priv/static/schema/commands/lobby/change_command.json) - [Response](/priv/static/schema/messages/lobby/updated_message.json)

Changes the state of the lobby. You can change as many of the fields at once as you like, please refer to the [schema](/priv/static/schema/commands/lobby/change_command.json) for the list of what you can change and the format it needs to take.
```json
{
  "name": "lobby/change",
  "command": {
    "name": "New lobby name",
    "public?": true,
    "password": "password1"
  }
}
```

If successful, every connection subscribed to the lobby should get a `lobby/updated` message:
```json
{
  "name": "lobby/updated",
  "message": {
    "changes": {
      "name": "New lobby name",
      "password": "123",
      "passworded?": true,
      "public?": false,
      "update_id": 2
    }
  }
}
```

## `lobby/match_start`
[Request](/priv/static/schema/commands/lobby/match_start_command.json) - [Response](/priv/static/schema/messages/lobby/match_start_message.json)

Tells the server the match is starting and to update the lobby accordingly.
```json
{
  "name": "lobby/match_start",
  "command": {}
}
```

## `lobby/match_end`
[Request](/priv/static/schema/commands/lobby/match_end_command.json) - [Response](/priv/static/schema/messages/lobby/match_ended_message.json)

Tells the server the match is ending and to update the lobby accordingly. In it you will need to include some information on the outcome of the match and player specific results.
```json
{
  "name": "lobby/match_end",
  "command": {
    "winning_team": 1,
    "ended_normally?": true,
    "players": {
      "db246b29-5cf0-4aca-9686-bb68aa5768dc": {
        "left_after_seconds": 100
      },
      "07678a56-a26b-4bfe-b8f8-36f74d90633d": {}
    }
  }
}
```

# Host commands
## TODO: List commands supplied by host


