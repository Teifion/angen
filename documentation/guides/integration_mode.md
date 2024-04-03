# Integration mode
Developing against a server can be difficult, orchestrating actions of other users and reproducing different events all makes things much harder and slower. That's why Angen has `integration_mode`; when active the server will create multiple bots with predetermined behaviours allowing you to rapidly develop and test client applications against the server.

## Enabling integration mode
Integration mode is set as part of the `angen.vars` file, specifically the `ANGEN_INTEGRATION_MODE` variable which should be set to `TRUE` if the mode is to be enabled.

## Extra commands
When integration mode is enabled some extra commands are enabled.

[system/integration_data](/documentation/protocol/system.md#integration-data) will return information about the different bots in the system.

# Bots
The source for the bots are all located in [/lib/angen/dev_support/bots], each bot has a docstring at the top of the file explaining what it does.

