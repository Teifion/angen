#!/usr/bin/env bash

mix deps.get --only prod
MIX_ENV=prod mix compile

MIX_ENV=prod mix assets.deploy

# Generate the actual releas
mix phx.gen.release

# And now cleanup afterwards
mix phx.digest.clean --all


