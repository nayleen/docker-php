#!/usr/bin/env bash

set -euo pipefail

if [ "${DOCKER_INIT_DONE:-}" != 1 ]; then
  exec sudo --non-interactive --preserve-env /init.sh "$@"
fi

# trust certificates added to /usr/local/share/ca-certificates
update-ca-certificates &>/dev/null

# run app init scripts
init_scripts_dir="/app/etc/init.d"

find "$init_scripts_dir" -executable -type f -print | sort -V | while read -r initScript; do
  "$initScript" "$@"
done

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"
