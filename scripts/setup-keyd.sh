#!/usr/bin/env bash
# keyd setup that Nix can't manage on a non-NixOS host (needs sudo, lives in
# /etc). nixpkgs' keyd assumes services.keyd.enable, which doesn't exist here,
# so we install the config + a generated systemd unit ourselves.
# Called by home-manager activation OR runnable standalone.
#
# Usage: setup-keyd.sh <keyd-binary-path> <keyd-config-source>

set -euo pipefail

KEYD_BIN="${1:?missing keyd binary path}"
KEYD_CONF_SRC="${2:?missing keyd config source}"

KEYD_CONF_DST=/etc/keyd/default.conf
KEYD_UNIT_DST=/etc/systemd/system/keyd.service
KEYD_UNIT_TMP=$(mktemp)
trap 'rm -f "$KEYD_UNIT_TMP"' EXIT

# Generate the systemd unit with the actual keyd binary path baked in
cat > "$KEYD_UNIT_TMP" << UNIT
[Unit]
Description=Keyd key remapping daemon

[Service]
Type=simple
ExecStart=${KEYD_BIN}
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

# Only sudo if something actually changed
needs_sudo=0
if [ ! -f "$KEYD_CONF_DST" ] || ! cmp -s "$KEYD_CONF_SRC" "$KEYD_CONF_DST"; then
    needs_sudo=1
fi
if [ ! -f "$KEYD_UNIT_DST" ] || ! cmp -s "$KEYD_UNIT_TMP" "$KEYD_UNIT_DST"; then
    needs_sudo=1
fi

if [ "$needs_sudo" = "1" ]; then
    echo ">>> keyd: updating /etc (sudo required)"
    sudo install -Dm644 "$KEYD_CONF_SRC" "$KEYD_CONF_DST"
    sudo install -Dm644 "$KEYD_UNIT_TMP" "$KEYD_UNIT_DST"
    sudo systemctl daemon-reload
    sudo systemctl enable keyd 2>/dev/null || true
    sudo systemctl restart keyd
    echo ">>> keyd: ready"
else
    echo ">>> keyd: already up to date"
fi
