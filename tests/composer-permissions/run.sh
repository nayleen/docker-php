#!/usr/bin/env bash

set -eou pipefail

SCRIPT_FULLPATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_REALPATH=$(dirname -- "$SCRIPT_FULLPATH")

if [ "$(pwd)" != "$SCRIPT_REALPATH" ]; then
    echo "Please run this script from the directory"
    exit 1
fi

if ! docker compose pull --quiet; then
    echo "Docker image pull failed :("
    exit 1
fi

if ! docker compose run --rm composer; then
    echo "Composer install failed :("
    exit 1
fi

echo "Composer install succeeded!"
