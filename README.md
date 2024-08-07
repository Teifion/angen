# Angen
A fast and reliable Elixir middleware server built on top of [Teiserver](https://github.com/Teifion/teiserver).

Documentation is found in [the documentation folder](documentation), protocol schemas are in [priv/static/schema](priv/static/schema). Additionally [Teiserver itself](https://hexdocs.pm/teiserver/Teiserver.html) has documentation describing things such as how the middleware server works.

# Features
Angen provides features allowing you to run your own middleware server and leverage all the benefits of that, broadly speaking these would be:
- JSON based protocol for realtime communication include server-pushed updates
- Scalability
- Crossplay
- Social features
- Discoverability (the ability to search for ongoing games)
- Matchmaking
- Event telemetry
- Integration mode to assist with development and testing

## Telemetry collector server
Angen can be used purely as a telemetry event collector server. For full details on this please see the [telemetry event guide](documentation/guides/admin/telemetry_events.md).

## Cost
Angen is free software under the [Apache license](LICENSE.txt), the only cost to using it is the servers you spin up. Angen is currently still in development but the expectation is for up to 200 concurrent users it can be run from a single small VPS for around $10-15 a month.

## Deployment
<!-- TODO: Improve this bit -->
Run `scripts/build_container.sh` to generate the container and build the artefact, it will place said artefact in `rel/artifacts/angen.tar.gz` which you can then upload. There is an ansible script to setup the server(s) and another to perform deployments.
