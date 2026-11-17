#!/usr/bin/env bash
# Install the Firefox policy file: the extensions we always use and a few
# defaults (no telemetry, Pocket or sponsored tiles; no password saving).
# Firefox reads it from /etc/firefox/policies at start. Idempotent: sudo only
# when the file changed.
#
# Usage: setup-firefox.sh <policies.json>
set -euo pipefail

SRC="${1:?missing policies.json}"
DST=/etc/firefox/policies/policies.json

if ! cmp -s "$SRC" "$DST"; then
    echo ">>> firefox: installing $DST (sudo required)"
    sudo install -Dm644 "$SRC" "$DST"
fi
