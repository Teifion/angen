# Authorised telemetry events
These are events which will be tied to a user, to submit them you must be authorised though each event does allow you to submit them on behalf of another user (useful if you want something like a match-host to be doing the submitting rather than user applications). There is a section on anonymous events further down the page.

### Simple clientapp event
[Example bru](/bru/Telemetry_events/Create_simple_clientapp_event.bru)
- Method: `POST`
- URL: `api/events/simple_clientapp`

The body of the message should be a JSON list of objects:

Required:
- name: A string of the event name
  
Optional
- user_id: The ID of the user this is for (by default it will attribute the event to the user making the request)

Example request
```json
[
  {"name": "clicked-matchmaking"},
  {"name": "found-match"},
  {"name": "clicked-matchmaking", "user_id": "d9b39e1a-00fe-4b9e-9e99-4dc4e964ceaa"}
]
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 3
}
```

### Complex clientapp event
[Example bru](/bru/Telemetry_events/Create_complex_clientapp_event.bru)
- Method: `POST`
- URL: `api/events/complex_clientapp`

The body of the message should be a JSON list of objects:

Required:
- name: A string of the event name
- details: A json object containing details of the event
  
Optional
- user_id: The ID of the user this is for (by default it will attribute the event to the user making the request)

Example request
```json
{
  "events": [
    {"name": "daily-feedback", "details": {"gameplay": 5, "community": 4}},
    {"name": "completed-tutorial", "details": {"time_taken_seconds": 601}},
    {"name": "daily-feedback", "user_id": "56dabb7f-0c4a-43d3-9d66-6474aa761fc9", "details": {"gameplay": 3, "community": 5}}
  ]
}
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 4
}
```

### Simple match event
[Example bru](/bru/Telemetry_events/Create_simple_match_event.bru)
- Method: `POST`
- URL: `api/events/simple_match?match_id=SOME_UUID`
- Params:
  - match_id: The UUID of the match this event takes place in, the match must exist in the database to create the event

The body of the message should be a JSON list of objects:

Required:
- name: A string of the event name
- seconds: An integer representing the number of seconds since match start when the event took place
  
Optional
- user_id: The ID of the user this is for (by default it will attribute the event to the user making the request)
  
Example request
```json
[
  {"name": "produced-first-worker", "seconds": 123},
  {"name": "used-auto-scout", "seconds": 456},
  {"name": "ultimate-ability", "seconds": 199},
  {"name": "produced-first-worker", "seconds": 111, "user_id": "d9b39e1a-00fe-4b9e-9e99-4dc4e964ceaa"}
]
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 4
}
```

### Complex match event
[Example bru](/bru/Telemetry_events/Create_complex_match_event.bru)
- Method: `POST`
- URL: `api/events/complex_match?match_id=SOME_UUID`
- Params:
  - match_id: The UUID of the match this event takes place in, the match must exist in the database to create the event

The body of the message should be a JSON list of objects:

Required:
- name: A string of the event name
- seconds: An integer representing the number of seconds since match start when the event took place
- details: A json object containing details of the event
  
Optional
- user_id: The ID of the user this is for (by default it will attribute the event to the user making the request)

Example request
```json
{
  "events": [
    {"name": "first-completion", "details": {"unit": "tank-factory"}, "seconds": 98},
    {"name": "initial-tech-choice", "details": {"tech": "writing"}, "seconds": 6},
    {"name": "died", "details": {"source": "falling"}, "user_id": "56dabb7f-0c4a-43d3-9d66-6474aa761fc9", "seconds": 188}
  ]
}
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 3
}
```

# Anonymous telemetry events
These events are not tied to a user and you do not need to be authenticated to submit them (even if you are authenticated the user_id will not be stored against the event). A hash can be provided as part of the URL params, if not a random hash will be generated for each event.

### Simple anon event
[Example bru](/bru/Telemetry_anon_events/Create_simple_anon_event.bru)
- Method: `POST`
- URL: `api/events/simple_anon`

The body of the message should be a JSON list of objects:

Required:
- name: A string of the event name

Optional:
- hash: A UUID which will be stored against the event allowing for grouping of events. If you do not want events to be grouped leave this empty and a random one will be generated.

Example request
```json
[
  {"name": "started campaign", "hash": "283218f3-958a-400e-a7a3-6cb0aff0b489"},
  {"name": "started skirmish", "hash": "283218f3-958a-400e-a7a3-6cb0aff0b489"},
  {"name": "started multiplayer"}
]
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 3
}
```

### Complex anon event
[Example bru](/bru/Telemetry_anon_events/Create_complex_anon_event.bru)
- Method: `POST`
- URL: `api/events/complex_anon`

The body of the message should be a JSON list of objects:

Required:
- name: A string of the event name
- details: A json object containing details of the event

Optional:
- hash: A UUID which will be stored against the event allowing for grouping of events. If you do not want events to be grouped leave this empty and a random one will be generated.

Example request
```json
{
  "events": [
    {"name": "daily-feedback", "details": {"gameplay": 5, "community": 4}},
    {"name": "completed-tutorial", "details": {"time_taken_seconds": 601}, "hash": "30148b94-f103-45ba-8580-c8c79bb9b372"},
    {"name": "system-specs", "details": {"vram": 6, "ram": 32}}
  ]
}
```

Example success
```json
{
  "result": "Event(s) created",
  "count": 3
}
```