# Protocol
Files are broken into a few sections:
- [schema](/priv/static/schema) for the JSON schema files (this will later move to its own repo)
- [commands](/lib/angen/text_protocol/command_handlers) to handle commands from client applications
- [infos](/lib/angen/text_protocol/info_handlers) to handle internal (PubSub) messages
- [responses](/lib/angen/text_protocol/responses) to create and send messages to client applications
- [documentation](/documentation/protocol) for explanations on the protocol itself
- [tests](/test/angen/text_protocol) for automated tests
- [integration bots](/lib/angen/dev_support) for assisting client application developers integrate with the server and protocol

## Commands
Adding a new command will require you to:
- Add a new schema and command which can be made easier with `mix angen.generate.command {section} {command}`
- Possibly add a new response (see next section)
- Document the new command
- Add tests for the new command
- Possibly add or extend an integration bot (and add the relevant tests for it)

## Responses
Adding a new response will require you to:
- Possibly add a new command or info (see previous or next section)
- Add a new schema and message handler which can be made easier with `mix angen.generate.response {section} {command}`
- Document the new response
- Add tests for the new response
- Possibly add or extend an integration bot (and add the relevant tests for it)

