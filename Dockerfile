FROM elixir:1.17.1
ARG env=dev
ENV LANG=en_US.UTF-8 \
    TERM=xterm \
    MIX_ENV=$env
WORKDIR /opt/build
CMD ["bin/build_script"]
