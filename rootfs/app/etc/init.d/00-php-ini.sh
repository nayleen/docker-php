#!/usr/bin/env bash

set -euo pipefail

# symlink php.ini depending on chosen template
target="/app/etc/php/php.ini-$PHP_INI_TEMPLATE_FILE"
[ "$(readlink /app/etc/php/php.ini)" = "$target" ] || ln -sf "$target" /app/etc/php/php.ini
