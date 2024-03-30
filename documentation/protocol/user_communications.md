# User communications
For communicating with other users

# Direct messages
## Send direct message
[Request](/priv/static/schema/commands/communication/send_direct_message_command.json)

```json
{
  "name": "communication/send_direct_message",
  "command": {
    "to_id": "user-id",
    "content": "Test message"
  }
}
```

## Receive direct message
[Response](/priv/static/schema/messages/communication/received_direct_message.json)

Sent when you receive a direct message from another user.

```json
{
  "name": "communication/received_direct_message",
  "message": {
    "message": {
      "content": "Test message",
      "delivered?": false,
      "sender_id": "3fa9944f-f4ea-4778-822a-e9f4b88b7a1b",
      "inserted_at": "2024-03-05T00:06:40.888869Z",
      "read?": false,
      "to_id": "b3a14fc1-de31-4b7d-b289-dccd6986a564"
    }
  }
}
```

## List recent direct messages


# Rooms
## List rooms

## Join room

## Leave room

## List recent room messages

## Send room message

## Receive room message


# Lobbies
## List recent lobby messages

## Send lobby message

## Receive lobby message


# Parties
## List recent party messages

## Send party message

## Receive party message

