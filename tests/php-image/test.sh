#!/usr/bin/env bash

set -euo pipefail

fail() {
  echo "::error $1" >&2
  exit 1
}

[ "$$" = 1 ] || fail "Default command is not PID 1"
[ "$(id -u)" = 1000 ] || fail "Default command is not rootless"

actual_php_version=$(php -r 'printf("%d.%d", PHP_MAJOR_VERSION, PHP_MINOR_VERSION);')
[ "$actual_php_version" = "$EXPECTED_PHP_VERSION" ] || fail "Expected PHP $EXPECTED_PHP_VERSION, got PHP $actual_php_version"

php_modules=$(php -m)
required_modules=(
  bcmath curl FFI igbinary intl json mbstring msgpack openssl pcntl
  pcre shmop sockets sysvmsg uuid uv xdebug zip zstd "Zend OPcache"
)

for module in "${required_modules[@]}"; do
  grep --fixed-strings --line-regexp --quiet "$module" <<< "$php_modules" || fail "PHP extension $module is not enabled"
done

check_ini() {
  local setting=$1
  local expected=$2
  local actual
  actual=$(php -r "echo ini_get(\$argv[1]);" "$setting")
  [ "$actual" = "$expected" ] || fail "Expected $setting=$expected, got $actual"
}

check_ini date.timezone UTC
check_ini expose_php ""
check_ini xdebug.mode off

openssl req -x509 -newkey rsa:2048 -nodes -subj /CN=test \
  -keyout /tmp/test.key \
  -out /usr/local/share/ca-certificates/test.crt \
  -days 1 >/dev/null 2>&1
update-ca-certificates >/dev/null 2>&1
openssl verify /usr/local/share/ca-certificates/test.crt | grep --quiet ': OK$'
