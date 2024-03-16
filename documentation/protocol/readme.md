# Protocol documentation
Angen makes use of a JSON schema as defined in [/priv/static/schema](/priv/static/schema). If the documentation and schema ever disagree; this is a bug and should be raised as an issue. The schema should always be considered the source of truth; the purpose of the documentation is to make using the schema a bit easier.

## Terminology

| Term               | Meaning                                                                                                                         |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| AI                 | User-owned game AI instances                                                                                                    |
| Autohost           | A bot which is specifically intended to host battles                                                                            |
| Bot                | An automated Client, marked as a bot                                                                                            |
| Client             | The online representation of a user as per `types/connections/full_client.json` and `types/connections/partial_client.json`     |
| Client Application | An application run on a person's computer which connects to the middleware server and facilitates entering a match              |
| Command            | The JSON data sent in a Request from the Client to the Server                                                                   |
| Command name       | The unique string which represents the command type. E.g. `system/ping` or `lobby/open`                                         |
| Host               | The host of a lobby                                                                                                             |
| Lobby              | A room or waiting area from which a Match can be launched, one Lobby can have multiple Matches over the course of its lifetime  |
| Match              | An instance of a game being played by 1 or more players, can refer to a match about to happen, in progress or in the past       |
| Message            | The JSON data sent as part of a Response from the Server to the Client                                                          |
| Message ID         | A unique identifier for a request/response pair which links them together                                                       |
| Server             | The provider of the protocol and what clients connect to. i.e. the master/middleware server                                     |
| User               | Syonymous with an account, and strictly represents the data which is stored in the server database                              |

## Request / Response process
Clients message the server using Requests and receive Responses. A request wraps around a command and a response wraps around a message. Wrapping allows us to include generic or universal data such as the `message_id`.

Nearly every Request will result in a Response of some sort. In some cases it will be a specific response (e.g. registering a user will result in you being told your user_id) while in others it will be a generic response (Success, Failure or Error).

## Request structure
A request consists of 3 properties:
- **`name`**: The name of the command being sent
- **`command`**: The command itself which must adhere to the relevant command schema
- **`message_id`** (optional): A message ID which any direct responses to this command should include

```json
{
  "name": "command/name",
  "command": {
    "key1": "value1",
    "key2": "value2"
  },
  "message_id": "optional message id"
}
```

## Response structure
Responses will consist of up to 3 properties:
- **`name`**: The name of the message being sent
- **`message`**: The message itself which must adhere to the relevant message schema
- **`message_id`** (optional): If the message is a direct response to a request with a message_id then the message_id will be included

```json
{
  "name": "message/name",
  "message": {
    "key1": "value1",
    "key2": "value2"
  },
  "message_id": "optional message id"
}
```

## Generic response messages
Many commands will have specific response messages but in some cases there will be a generic "success" message and if something goes wrong you should expect to receive a "failure" or "error" message.

### Success
When a command succeeds but has no further information to send back 

### Failure

### Error

## Documentation
- [Account](account.md)
- [Authentication](authentication.md)
- [Connections](connections.md)
- [Lobby - Hosts](lobby_hosts.md)
- [Lobby - Users](lobby_users.md)
- [Matchmaking](matchmaking.md)
- [Social](social.md)
- [System](system.md)
- [Telemetry](telemetry.md)
- [User communication](user_communication.md)
- [User settings](user_settings.md)
