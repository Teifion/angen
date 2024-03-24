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
  "message": {
    "bots": [
      {"id": "32e5b4d1-13e9-4c7e-84ae-de80643e6992", "name": "IntegrationBot1"},
      {"id": "16fb7c67-741f-4391-a609-1187fce6b1d2", "name": "IntegrationBot2"},
      {"id": "cb7ec06e-a5ae-4803-8c2a-a8e4858bcc3f", "name": "IntegrationBot3"}
    ]
  }
}
```

