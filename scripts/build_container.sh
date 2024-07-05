#!/usr/bin/env bash
# This is called by your build script to build the artefact in the docker container
docker buildx build --build-arg env=prod -t angen:latest .
docker run -v $(pwd):/opt/build --rm -it angen:latest /opt/build/scripts/docker_build_script
