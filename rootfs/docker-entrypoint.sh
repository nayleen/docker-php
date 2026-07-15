#!/usr/bin/env bash

set -euo pipefail

# trust certificates added to /usr/local/share/ca-certificates
update-ca-certificates &>/dev/null

# fix permissions for the app user based on the filesystem mounted at /app/src
DOCKER_USER_ID=$(/usr/local/bin/fix-app-folder-permissions)
DOCKER_USER_NAME=$(id -un "$DOCKER_USER_ID")
DOCKER_USER_GROUP_ID=$(id -gr "$DOCKER_USER_ID")

export HOME=$(getent passwd "$DOCKER_USER_ID" | cut -d: -f6)
export LOGNAME="$DOCKER_USER_NAME"
export SHELL=$(getent passwd "$DOCKER_USER_ID" | cut -d: -f7)
export USER="$DOCKER_USER_NAME"

# run app init scripts as the app user
init_scripts_dir="/app/etc/init.d"

find "$init_scripts_dir" -executable -type f -print | sort -V | while read -r initScript; do
  setpriv --reuid "$DOCKER_USER_ID" --regid "$DOCKER_USER_GROUP_ID" --init-groups "$initScript" "$@"
done

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec setpriv --reuid "$DOCKER_USER_ID" --regid "$DOCKER_USER_GROUP_ID" --init-groups "$@"
