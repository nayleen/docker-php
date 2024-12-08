#!/usr/bin/env bash

set -euo pipefail

# pass docker CMD to /init.sh, which will execute it as the correct user
exec "sudo" "-E" "-H" "/init.sh" "$@"
