#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

IMAGE=$(jq --raw-output --arg version "$1" '.[$version] // empty' php-images.json)

if [ -z "$IMAGE" ]; then
  echo "Unsupported PHP version: $1" >&2
  exit 1
fi

if [[ ! "$IMAGE" =~ ^docker\.io/library/php:([0-9]+\.[0-9]+)\.[0-9]+-cli@sha256:[a-f0-9]{64}$ ]] || [ "${BASH_REMATCH[1]:-}" != "$1" ]; then
  echo "Invalid PHP image for version $1: $IMAGE" >&2
  exit 1
fi

echo "$IMAGE"
