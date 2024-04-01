# Lobby users
For general interactions with lobbies.

## `lobby/query`
[Request](/priv/static/schema/commands/lobby/query_command.json) - [Response](/priv/static/schema/messages/lobby/list_message.json)

Used to query lobbies.

```json
{
  "name": "lobby/query",
  "command": {
    "filters": {
      "match_ongoing?": false,
      "locked?": false
    }
  }
}
```

You will get a response of a list of lobbies:
```json
{
  "name": "lobby/list",
  "message": {
    "lobbies": [
      {
        "game_name": "BestGameEver",
        "game_version": "v12.34.56",
        "host_id": "ae7634aa-a353-4107-a205-c5bbc3f0d15b",
        "id": "538f4ed3-7150-40a8-a50b-e04dac56586b",
        "locked?": false,
        "match_ongoing?": false,
        "name": "test-5708afc6-ff9d-4930-99d4-e1d5e979db1c",
        "passworded?": false,
        "player_count": 0,
        "public?": true,
        "rated?": true,
        "spectator_count": 0,
        "tags": []
      }
    ]
  }
}
```

## `lobby/join`
[Request](/priv/static/schema/commands/lobby/join_command.json) - [Response](/priv/static/schema/messages/lobby/list_message.json)

Used to join lobbies. If a lobby is not passworded then the password need not be supplied.

```json
{
  "name": "lobby/join",
  "command": {
    "id": "7dbee2e8-871d-4560-900a-5831ee36c726",
    "password": "password1"
  }
}
```

If successful the you will be sent a shared secret (known only to you and the host) allowing the in-game client to confirm your identity without having to go via the middleware server.

```json
{
  "name": "lobby/joined",
  "message": {
    "lobby": {
      "approved_members": [],
      "game_name": "Best Game This Year",
      "game_settings": {},
      "game_version": "v123",
      "host_data": {},
      "host_id": "9846df9c-4c89-4df1-845a-cfea214e5d11",
      "id": "cadc6555-dcf7-4e05-915b-58e21a8fc040",
      "locked?": false,
      "match_id": "f878d389-e654-476c-8ca3-e223c490d479",
      "match_ongoing?": false,
      "match_type": "team",
      "members": [],
      "name": "My lobby name",
      "password": null,
      "passworded?": false,
      "players": [],
      "public?": true,
      "queue_id": null,
      "rated?": true,
      "spectators": [],
      "tags": []
    },
    "shared_secret": "wQMQUqqsKj8GdW1t+TAWV7qmA5BCoaUTi13xsgwZelT/KbuUiKsELHD9iSkeVr/t"
  }
}
```

## `lobby/leave`
[Request](/priv/static/schema/commands/lobby/leave_command.json)

```json
{
  "name": "lobby/leave",
  "command": {}
}
```

## `lobby/update_client`
Sends a request to change your client. The server may deny the change and depending on settings the host may also deny the change. You will get a success message if the command is submitted correctly but the results of the change will be present in a `connections/client_updated` message. If no change is performed then no updated message will be sent.

```json
{
  "name": "lobby/update_client",
  "command": {
    "player?": true,
    "player_number": 123,
    "team_number": 456,
    "team_colour": "#458812"
  }
}
```


## Lobby state change
[Response](/priv/static/schema/messages/lobby/updated_message.json)

Sent when the state of a lobby changes.

```json
{
  "name": "lobby/updated",
  "message": {
    "changes": {
      "name": "New lobby name",
      "update_id": 2
    }
  }
}
```

## Subscribe to lobby updates

## Unsubscribe from lobby updates

# Votes
## Vote history

## Ongoing votes

## Vote started

## Vote completed

## Start vote

## Cancel vote

## Perform vote

# Chat
## Send message
Send a message visible to all users in the lobby.

```json
{
  "name": "lobby/send_message",
  "command": {
    "content": "Test message"
  }
}
```

## Receive message
When a message was sent to a lobby you subscribe to.

```json
{
  "message": {
    "lobby_id": "ae03a6af-dd99-4c24-9409-3bdf46861e3a",
    "message": {
      "content": "Test message",
      "inserted_at": "2024-03-29T21:34:22Z",
      "match_id": "e969f5ef-c55d-4fd1-a58e-408a3ec4fc6a",
      "sender_id": "95023c95-8672-44f6-a9f9-ce45c424feb4"
    }
  },
  "name": "lobby/message_received"
}
```

-- Still deciding if I want to add this or not, it is not set in stone --

## Whisper
A message only visible to the sender and recipient. Can be configured to be allowed or not with a runtime setting.

## Receive whisper
```