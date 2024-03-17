# System commands

## Ping
[Request](/priv/static/schema/commands/system/ping_command.json) - [Response](/priv/static/schema/messages/system/pong_message.json)
Sends a ping and gets a pong response. No actions are performed and you do not need to be authenticated. If you use a local timestamp with the ping on the `message_id` it will be returned with th pong allowing for easy tracking of latency to the server.
```json
{
  "name": "system/ping",
  "command": {}
}
```

```json
{
  "name": "system/pong",
  "message": {}
}
```

## TODO: List nodes
List nodes we can connect to.
```json
{
  "name": "system/",
  "command": {}
}
```

```json
{
  "name": "system/",
  "message": {}
}
```

