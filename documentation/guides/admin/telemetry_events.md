# Overview
Telemetry events allow you to track what has happened and when. They allow you insight into how your program is being used; the information gleaned from this data can be incredibly useful to designing and improving your program.

## Privacy warning
I am not a lawyer and this is not legal advice so if you have any uncertainties around what you can/cannot collect please consult someone who is.

It is very important to understand a number of things regarding telemetry events before we start. The number one item to consider is privacy. Telemetry events can be anything from "resources spent on a specific mission" all the way to hardware specs. Thus the first thing to be clear on is what data you are collecting and if any of it falls under a relevant law (think GDPR) and what consent you must obtain for it.

## Event categories
Angen makes use of 5 different types of event:
- **Anonymous**: Client-side events not attached to a user
- **Clientapp**: Client-side events which are attached to a user
- **Match**: Events taking place within an instance of a game
- **Server**: Events taking place within the server
- **Lobby**: Events taking place within a lobby (so still server-side)

Each of these 5 events has both a simple and a complex style. Simple events just record the event took place with no extra details; they are very small and take up very little space so you can have a lot of them. Complex events come with a key-value blob of data so take up more space and require slightly more processing.

Complex events do not enforce any structure or consistency on the data blob, it is advised for data analysis purposes to be consisting for each type of event type to always have the same structure.

# Submitting and emitting events
Angen provides several ways to submit events to the server.

## TCP Protocol
- `events/anonymous`
- `events/client`
- `events/match`

## HTTP Interface
- `events/anonymous`
- `events/client`
- `events/match`

# Extracting data
Angen provides some web interfaces for exploring collected data but for professional data analysts there are tools to export the data for use in tools better suited to the role.

Angen has an API allowing returning of a zip containing CSVs.

# Third party services
I want to add the ability to forward all telemetry data straight to third parties making it easier to scales games in future but I've not had a chance to do this yet. If this is something you want please create a [github issue](https://github.com/Teifion/angen/issues) or [Pull Request](https://github.com/Teifion/angen/pulls) for it.



<!-- 
# TODO: Events used in BAR-Teiserver which might be of use to include in Angen

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
-->
