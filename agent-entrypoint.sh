#!/bin/sh
set -eu

SECRET_PATH="/run/secrets/cursor_api_key"

exec /usr/local/bin/agent -f --api-key "$(cat "$SECRET_PATH")"

