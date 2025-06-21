#!/usr/bin/env bash

set -euo pipefail

# trust certificates added to /usr/local/share/ca-certificates
update-ca-certificates &>/dev/null

# fix permissions for the app user based on the filesystem mounted at /app/src
DOCKER_USER_ID=$(/usr/local/bin/fix-app-folder-permissions)

# run app init scripts as the app user
init_scripts_dir="/app/etc/init.d"

find "$init_scripts_dir" -executable -type f -print | sort -V | while read -r initScript; do
  sudo -E -u "#$DOCKER_USER_ID" "$initScript" "$@"
done

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "sudo" "-E" "-H" "-u" "#$DOCKER_USER_ID" "$@"
