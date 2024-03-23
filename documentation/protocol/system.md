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

## List nodes
[Request](/priv/static/schema/commands/system/nodes_command.json) - [Response](/priv/static/schema/messages/system/nodes_message.json)

Lists nodes in the cluster. Authentication is not required for this command.
```json
{
  "name": "system/nodes",
  "command": {}
}
```

```json
{
  "name": "system/nodes",
  "message": {
    "nodes": [
      "node1.domain.co.uk",
      "node2.domain.co.uk"
    ]
  }
}
```

## Integration data
[Request](/priv/static/schema/commands/system/integration_data_command.json) - [Response](/priv/static/schema/messages/system/integration_data_message.json)

If Integration mode is active, return data relevant to using it. If not return a generic failure. Authentication is not required for this command.
```json
{
  "name": "system/integration_data",
  "command": {}
}
```

```json
{
  "name": "system/integration_data",
  "message": {}
}
```

