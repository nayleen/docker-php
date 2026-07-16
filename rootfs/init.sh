#!/usr/bin/env bash

set -euo pipefail

mounted_uid=$(stat -c %u /app/src)

if [ "$mounted_uid" != 0 ] && [ "$mounted_uid" != "$(id -u app)" ]; then
  usermod --non-unique --uid "$mounted_uid" app
fi

# Include separately mounted paths such as /app/var/composer.
chown -R app /app /etc/ssl/certs /usr/local/share/ca-certificates

export DOCKER_INIT_DONE=1 HOME=/home/app LOGNAME=app SHELL=/bin/bash USER=app

exec setpriv --reuid app --regid app --init-groups /docker-entrypoint.sh "$@"
