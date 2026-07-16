#!/usr/bin/env bash

set -euo pipefail

# trust certificates added to /usr/local/share/ca-certificates
if ! update-ca-certificates &>/dev/null; then
  echo "warning: could not update CA trust store as UID $(id -u)" >&2
fi

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
