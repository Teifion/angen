# Overview

## Privacy warning
- Understand what PII is
- Know the laws of wherever you are providing a service
- I am not a lawyer, if in doubt don't collect data

## Event categories
- Server
- Lobby
- ClientApp
- Match

## Limitations

## Extension
- How to extend it to add new data

## Third party services
I want to add the ability to forward all telemetry data straight to third parties making it easier to scales games in future but I've not had a chance to do this yet. If this is something you want please create a [github issue](https://github.com/Teifion/teiserver/issues) or [Pull Request](https://github.com/Teifion/teiserver/pulls) for it.


SIMPLE SERVER EVENTS
lobby.force_add_user_to_lobby
lobby.recheck_membership_kick
lobby.recheck_membership_spectate
has_warning.remove_user_from_any_lobby
account.user_login
disconnect:#{reason}
lobby_policy.kicked_for_bossing
lobby.kicked_from_web_interface

COMPLEX SERVER EVENTS
spads.broken_connection (from_id)
Banned login (reason)

SIMPLE LOBBY EVENTS
remove_user_from_lobby
lobby.kick_user
lobby.match_stopped
lobby.manual_stop
consul.timeout_command
consul.lobbykick_command
consul.lobbyban_command
consul.lobbybanmult_command
play_refused.avoiding
play_refused.avoided
play_refused.boss_avoided
join_refused.blocking
join_refused.blocked
join_refused.boss_blocked
Kicked user from lobby
command.rename (new_name)
Spec command (caller, spectated, name used to call command)

