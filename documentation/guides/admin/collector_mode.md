# Pure collector mode
By default Angen expects you to be using it as a middleware server so it is already aware of lobbies, matches and users when telemetry events are submitted. Pure collector mode enables additional interfaces to create users and matches via commands. These entities are purely for database purposes and to allow correct relational data to be stored.

## Enabling pure collector mode
This is done by enabling the [server setting](settings.md) "Pure collector mode" (internal key `pure_collector_mode`). When enabled all the below interfaces will be enabled. If it is not enabled they will be disabled.

**Note:** If you are using Angen as a middleware server you should not enable this setting. If you have any questions please contact the Angen developers.

# Administrative HTTP endpoints
Please see [client/http_api](../client/http_api.md) for the non-administrative endpoints related to the http api including authentication.

# User accounts
## Creating users

## Updating users


# Matches
## Creating matches

## Updating matches


