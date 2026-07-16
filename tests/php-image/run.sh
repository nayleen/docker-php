#!/usr/bin/env bash

set -eou pipefail

SCRIPT_FULLPATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_REALPATH=$(dirname -- "$SCRIPT_FULLPATH")

if [ "$(pwd)" != "$SCRIPT_REALPATH" ]; then
    echo "Please run this script from the directory"
    exit 1
fi

exit_code=0

PHP_INI_OUTPUT=$(docker compose run --rm php php -i)
PHP_MODULES_OUTPUT=$(docker compose run --rm php php -m)

# check rootless execution and the downstream explicit-user case
docker compose run --rm php php -r 'exit(posix_geteuid() === 1000 && getmypid() === 1 ? 0 : 1);'
docker compose run --rm --user 1000:1000 php php -r 'exit(posix_geteuid() === 1000 && posix_getegid() === 1000 && getmypid() === 1 ? 0 : 1);'

# arbitrary UIDs in group 0 can extend the trusted CA bundle
docker compose run --rm --user 4711:0 php bash -c \
  'openssl req -x509 -newkey rsa:2048 -nodes -subj /CN=test -keyout /tmp/test.key -out /usr/local/share/ca-certificates/test.crt -days 1 >/dev/null 2>&1 && update-ca-certificates >/dev/null && openssl verify /usr/local/share/ca-certificates/test.crt | grep -q ": OK$"'

log_error() {
  echo "::error $1"
}

validate_php_ini_setting() {
  VALUE=$(echo "$PHP_INI_OUTPUT" | grep "$1" | awk -F' => ' '{print $2}')

  if [ "$VALUE" != "$2" ]; then
    log_error "PHP .ini setting '$1' does not match expected value '$2' (instead: '$VALUE') for PHP ${PHP_VERSION} Base Image"
    exit_code=1
  fi
}

validate_php_module() {
  if ! (echo "$PHP_MODULES_OUTPUT" | grep --quiet "$1"); then
    log_error "PHP Module '$1' is not enabled for PHP ${PHP_VERSION} Base Image"
    exit_code=1
  fi
}

if ! docker compose pull --quiet; then
    echo "Docker image pull failed :("
    exit 1
fi

# check extensions
validate_php_module "bcmath"
validate_php_module "curl"
validate_php_module "FFI"
validate_php_module "igbinary"
validate_php_module "intl"
validate_php_module "json"
validate_php_module "mbstring"
validate_php_module "msgpack"
validate_php_module "openssl"
validate_php_module "pcntl"
validate_php_module "pcre"
validate_php_module "shmop"
validate_php_module "sockets"
validate_php_module "sysvmsg"
validate_php_module "uuid"
validate_php_module "uv"
validate_php_module "xdebug"
validate_php_module "zip"
validate_php_module "zstd"
validate_php_module "Zend OPcache"

# check php.ini settings
validate_php_ini_setting "date.timezone" "UTC"
validate_php_ini_setting "expose_php" "Off"
validate_php_ini_setting "xdebug.mode" "off"

[ $exit_code -eq 0 ] && echo "PHP image is working as expected!" || echo "::error PHP image is not working as expected :("

exit $exit_code
