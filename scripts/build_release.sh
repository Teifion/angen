#!/usr/bin/env bash
docker run -v $(pwd):/opt/build --rm -it angen:latest /opt/build/bin/build

