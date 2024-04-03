# Angen
A fast and reliable Elixir middleware server built on top of [Teiserver](https://github.com/Teifion/teiserver).

Documentation is found in [the documentation folder](documentation), protocol schemas are in [priv/static/schema]. Additionally [Teiserver itself](https://hexdocs.pm/teiserver/Teiserver.html) has documentation describing things such as how the middleware server works.

# Features
Angen provides features allowing you to run your own [middleware](https://hexdocs.pm/teiserver/Teiserver.html) server and leverage all the benefits of that, broadly speaking these would be:
- JSON based protocol for realtime communication include server-pushed updates
- Scalability
- Crossplay
- Social features
- Discoverability (the ability to search for ongoing games)
- Matchmaking
- Event telemetry
- Integration mode to assist with development and testing

## Cost
Angen is free software under the [Apache license](LICENSE.txt), the only cost to using it is the servers you spin up. Angen is currently still in development but the expectation is for up to 200 concurrent users it can be run from a single small VPS for around $10-15 a month.
