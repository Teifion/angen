FROM elixir:1.15.7
ARG env=dev
ENV LANG=en_US.UTF-8 \
    TERM=xterm \
    MIX_ENV=$env
WORKDIR /opt/build
ADD ./bin/build ./bin/build
CMD ["bin/build"]
