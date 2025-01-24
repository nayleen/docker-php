#!/usr/bin/env bash

set -euo pipefail

# symlink php.ini depending on chosen template
ln -sf "/app/etc/php/php.ini-$PHP_INI_TEMPLATE_FILE" /app/etc/php/php.ini
