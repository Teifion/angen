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
%{
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

# Host commands
## List commands supplied by host


