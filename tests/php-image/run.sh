#!/usr/bin/env bash

set -eou pipefail

cd -- "$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
: "${PHP_VERSION:?PHP_VERSION must be set}"

docker compose --progress none run --rm \
  -e EXPECTED_PHP_VERSION="$PHP_VERSION" php \
  bash /test.sh

docker compose --progress none run --rm --user 1000:1000 php \
  php -r 'exit(posix_geteuid() === 1000 && posix_getegid() === 1000 && getmypid() === 1 ? 0 : 1);'

echo "PHP image is working as expected!"
