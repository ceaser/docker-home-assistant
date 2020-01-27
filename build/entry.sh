#!/usr/bin/env bash

# Exit immediately on non-zero return codes.
set -ex

# Run start command and append if only options given.
if [ "${1:0:1}" = '-' ]; then
  set -- /srv/homeassistant/bin/hass "$@"
fi

# Run boot scripts before starting the server.
if [ "$1" = "/srv/homeassistant/bin/hass" ]; then
  if [ -z "$(id -u homeassistant 2>/dev/null)" ]; then
    useradd -U -d /home/hassistant -s /bin/false homeassistant
    #usermod -G users homeassistant
  fi

  # Setup user/group ids
  if [ ! -z "${HOMEASSISTANT_UID}" ]; then
    if [ ! "$(id -u homeassistant)" -eq "${HOMEASSISTANT_UID}" ]; then

      # usermod likes to chown the home directory, so create a new one and use that
      # However, if the new UID is 0, we can't set the home dir back because the
      # UID of 0 is already in use (executing this script).
      if [ ! "${HOMEASSISTANT_UID}" -eq 0 ]; then
        mkdir /tmp/temphome
        usermod -d /tmp/temphome homeassistant
      fi

      # Change the UID
      usermod -o -u "${HOMEASSISTANT_UID}" homeassistant

      # Cleanup the temp home dir
      if [ ! "${HOMEASSISTANT_UID}" -eq 0 ]; then
        usermod -d /home/homeassistant homeassistant
        rm -Rf /tmp/temphome
      fi
    fi
  fi

  if [ ! -z "${HOMEASSISTANT_GID}" ]; then
    if [ ! "$(id -g homeassistant)" -eq "${HOMEASSISTANT_UID}" ]; then
      groupmod -o -g "${HOMEASSISTANT_UID}" homeassistant
    fi
  fi

  # Cache packages to /venv if found
  if [ -d /venv ]; then
    if [ -z "$(ls -A /venv)" ]; then
      cp -aR /srv/homeassistant/. /venv/
    fi
    rm -rf /srv/homeassistant
    ln -s /venv /srv/homeassistant
    if [ ! "$CHANGE_VENV_DIR_OWNERSHIP" == "false" ]; then
      chown -R homeassistant:homeassistant /venv
    fi
  fi

  if [ -d /config ]; then
    # if empty mounted directory
    if [ -z "$(ls -A /config)" ]; then
      echo "$HOMEASSISTANT_VERSION" > /config/HA_VERSION
    fi
  fi

  ## Change version if necessary
  . /srv/homeassistant/bin/activate
  if [ "$HOMEASSISTANT_VERSION" == "pre" ]; then
    pip3.7 install --pre --upgrade homeassistant
  elif [ "$HOMEASSISTANT_VERSION" != "$(cat /config/HA_VERSION)" ]; then
    pip3.7 install homeassistant==$HOMEASSISTANT_VERSION
  fi

  if [ ! "$CHANGE_VENV_DIR_OWNERSHIP" == "false" ]; then
    chown -R homeassistant:homeassistant /srv/homeassistant/*
  fi
  if [ ! "$CHANGE_CONFIG_DIR_OWNERSHIP" == "false" ]; then
    chown -R homeassistant:homeassistant /config
  fi

  update-ca-certificates --verbose
  set -- gosu homeassistant "$@"
fi

# Execute the command.
exec "$@"
