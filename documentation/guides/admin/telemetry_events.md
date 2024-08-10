# Overview
Telemetry events allow you to track what has happened and when. They allow you insight into how your game is being played; the information gleaned from this data can be incredibly useful to designing and improving your game.

## Privacy warning
I am not a lawyer and this is not legal advice so if you have any uncertainties around what you can/cannot collect please consult someone who is.

It is very important to understand a number of things regarding telemetry events before we start. The number one item to consider is privacy. Telemetry events can be anything from "resources spent on a specific mission" all the way to hardware specs. Thus the first thing to be clear on is what data you are collecting and if any of it falls under a relevant law (think GDPR) and what consent you must obtain for it.

# Categories
Angen makes use of 5 different types of event:

### Anonymous
Client-side events not attached to a user. They are submitted with a `hash_id` (UUID) allowing semi-anonymous events to be submitted. If the same client consistently submits the same UUID you are able to identify multiple events as belonging to the same client. If you are looking to have truly anonymous events then all clients should use the same `hash_id` or generate a unique one each time.

### Clientapp
Client-side events attached to a user. These are submitted via an authenticated connection so only the event type (and optional details as below) need to be sent.

### Match
Client-side but specifically related to an ongoing match. As the server is already aware of the match the user is in only the event data and elapsed time in seconds need to be sent.

### Server
These events are all generated from within Angen. They are useful for tracking the usage and health of the server.

### Lobby
Similar to server events but specifically from within a lobby.

## Complex events
Each of the above 5 categories has both a simple and a complex style. Simple events just record the event took place with no extra details; they are very small and take up very little space so you can have a lot of them. Complex events come with a key-value blob of data so take up more space and require slightly more processing.

Complex events do not enforce any structure or consistency on the data blob, it is advised for data analysis purposes to be consisting for each type of event type to always have the same structure.

# Submitting and emitting events
Angen provides several ways to submit events to the server.

## Socket based protocol
This is the preferred way to submit events. Events are submitted one at a time via the socket and added immediately.
- [events/anonymous](/documentation/protocol/events.md#anonymous)
- [events/client](/documentation/protocol/events.md#client)
- [events/match](/documentation/protocol/events.md#match)
- [events/host_match](/documentation/protocol/events.md#host-match)

## Telemetry collector and nothing else
The above mentioned telemetry events are intended to be used alongside the rest of the functionality in Angen. This means match events link to the match they are part of meaning you can cross-reference events with outcomes. Angen has options allowing you to skip some of these steps. This is documented in the [collector mode](collector_mode.md) guide.

# Outside of Angen
It's your data, you do what you want with it.

## Extracting data
Angen provides some web interfaces for exploring collected data but for professional data analysts you can export the data for use in tools better suited to the role.

Angen will have an API allowing returning of a zip containing CSVs.

## External applications
I want to add the ability to forward all telemetry data straight to third party services making it easier to scales games in future but I've not had a chance to do this yet. If this is something you want please create a [github issue](https://github.com/Teifion/angen/issues) or event better a [pull request](https://github.com/Teifion/angen/pulls) for it.

# Telemetry ideas
One of the more common questions I see is "why go to this effort?" so here are some basic ideas to get you started.

- Once a day players are given a poll showing 3 faces for a mood poll, you can now track self-reported player enjoyment
- The first time each player produces a unit producing structure each match, you now know what they opened with
- The first time each player uses any ability each match, now you know if the ability is actually used
- When a player performs a sub-optimal choice (e.g. reloading before the clip is empty) vs doing it optimally
- When a player attempts to do something that makes no sense, if it happens a lot it might be a design issue


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
