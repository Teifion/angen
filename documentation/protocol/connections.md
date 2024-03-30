# Client
Commands related to changing your client. Clients in the protocol are a representation of their [Teiserver object](https://hexdocs.pm/teiserver/Teiserver.Connections.Client.html).

## Command `connection/update_client`
[Request](/priv/static/schema/commands/connections/update_client_command.json)

Allows you to signal to the server and other users various changes to your client state. For Lobby related changes please see [lobby/update_client](lobby_users.md#updateclient)

```json
{
  "name": "connections/update_client",
  "command": {
    "afk?": true,
    "in_game?": false,
    "ready?": false,
    "sync": {
      "game": 100,
      "map": 30
    }
  }
}
```

## Message `connection/client_updated`
[Response](/priv/static/schema/messages/connections/client_updated_message.json)

A message from the server indicating a client has changed.

```json
{
  "name": "connections/client_updated",
  "message": {
    "changes": {
      "lobby_id": "701d07a2-3ae9-49b4-b918-a022fd1b43d1",
      "update_id": 1
    },
    "reason": "joined_lobby",
    "user_id": "3bfa28ac-e41b-4f55-a8de-dbf49ef280b5"
  }
}
```


## TODO: Login queue heartbeat


## TODO: Disconnect
Disconnects your connection. If this is the last connection for the client; the client will be destroyed. The application is assumed to be signalling the player no longer wishes to interact with the server and not intending to return as they might in a crash.
