# Matches
Internally any match events will need to point to a match for database consistency. This consistency allows you to correctly group events together and group them accordingly (e.g. match events for team games vs 1v1 games may look very different). To this end you are able to create matches via the http api.

### Create match
[Example bru](/bru/Matches/Create_match.bru)
- Method: `POST`
- URL: `api/game/create_match`

The body of the message should be a JSON object with the following:

Required:
- public?: Boolean
- rated?: Boolean saying if the game was rated (and thus implied to be more competitive)

Optional
- name: The name of the match
- tags: A list of strings
- type: A string categorising the game type (e.g. team, duel, ffa or any of your choosing)
- game_name: A string naming the game being played, in most cases this will always be the same thing but the support exists for multiple game types on a single Angen instance
- game_version: A string listing the version number of the game being played
- team_count: Integer, the number of player teams in the game
- team_size: Integer, the maximum size of any of the teams in the game
- player_count: Integer, the actual number of players playing (typically expected to be team_count * team_size but can vary in asymmetric games)
  
Example request
```json
{
  "name": "2v2 all welcome",
  "tags": ["match-made", "lang-en", "lang-de"],
  "public?": false,
  "rated?": true,
  "type": "team",

  "game_name": "game-app-name",
  "game_version": "1.3.12",

  "team_count": 2,
  "team_size": 2,
  "player_count": 4
}
```

Example success
```json
{
  "id": "ccc6ee89-8b8f-4add-bbc3-57c0c2c33ebb",
  "result": "Match created"
}
```

### Update match
[Example bru](/bru/Matches/Create_match.bru)
- Method: `POST`
- URL: `api/game/update_match`

The body of the message should be a JSON object with the following:

Required:
- id: The UUID of the match to be updated
- public?: Boolean
- rated?: Boolean saying if the game was rated (and thus implied to be more competitive)

Optional
- name: The name of the match
- tags: A list of strings
- type: A string categorising the game type (e.g. team, duel, ffa or any of your choosing)
- game_name: A string naming the game being played, in most cases this will always be the same thing but the support exists for multiple game types on a single Angen instance
- game_version: A string listing the version number of the game being played
- team_count: Integer, the number of player teams in the game
- team_size: Integer, the maximum size of any of the teams in the game
- player_count: Integer, the actual number of players playing (typically expected to be team_count * team_size but can vary in asymmetric games)
- winning_team: Integer
- ended_normally?: Boolean, used to indicate the game ended normally (as opposed to crashing or manually being stopped for some reason)
- lobby_opened_at: Datetime, the time the match lobby opened
- match_started_at: Datetime, the time the match started
- lobby_opened_at: Datetime, the time the match stopped
- match_duration_seconds: The duration of the match in seconds, tracking it separately to start and stop times means you can track playtime specifically (e.g. ignoring pauses)


Example request
```json
{
  "id": "0d011c85-2097-441c-bedf-062718e4f1b6",
  "name": "2v2 all welcome",
  "tags": ["match-made", "lang-en", "lang-de"],
  "public?": false,
  "rated?": true,
  "type": "team",

  "game_name": "game-app-name",
  "game_version": "1.3.12",
  
  "team_count": 2,
  "team_size": 2,
  "player_count": 4,

  "winning_team": 1,
  "ended_normally?": true,

  "lobby_opened_at": "2024-08-08 09:11:47",
  "match_started_at": "2024-08-08 09:14:22",
  "match_ended_at": "2024-08-08 09:18:42",

  "match_duration_seconds": 218
}
```

Example success
```json
{
  "result": "Match updated"
}
```