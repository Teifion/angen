# Client
Commands related to changing your client

## Command `connection/update_client`


## Message `connection/client_updated`


## TODO: Login queue heartbeat


## TODO: Disconnect
Disconnects your connection. If this is the last connection for the client; the client will be destroyed. The application is assumed to be signalling the player no longer wishes to interact with the server and not intending to return as they might in a crash.
