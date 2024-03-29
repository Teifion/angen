# Lobby users
For general interactions with lobbies.

## `lobby/query`

## `lobby/join`

## `lobby/leave`

## Lobby state change

## Subscribe to lobby updates

## Unsubscribe from lobby updates

## Update status
See connections

# Votes
## Vote history

## Ongoing votes

## Vote started

## Vote completed

## Start vote

## Canel vote

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