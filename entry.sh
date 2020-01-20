#!/usr/bin/env bash

# Exit immediately on non-zero return codes.
set -ex

# Run start command if only options given.
if [ "${1:0:1}" = '-' ]; then
  set -- ./srv/homeassistant/bin/hass
fi

# Run boot scripts before starting the server.
if [ "$1" = "./srv/homeassistant/bin/hass" ]; then
  ## Change version if necessary
  . /srv/homeassistant/bin/activate
  if [ "$HOMEASSISTANT_VERSION" != "$(cat /.version)" ]; then
    pip3 install homeassistant==$HOMEASSISTANT_VERSION
  elif [ "$HOMEASSISTANT_VERSION" == "pre" ]; then
    pip3 install --pre --upgrade homeassistant
  fi

  set -- gosu homeassistant "$@"
fi

# Execute the command.
exec "$@"
