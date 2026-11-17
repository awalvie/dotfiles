#!/usr/bin/env bash
# CachyOS setup that nix can't manage: pacman packages, /etc/keyd, services,
# the docker group and the Tailscale operator. Idempotent: sudo only when
# something has to change. Service steps only run on a booted systemd host.
# Login stays manual: run `tailscale up` once.
#
# Usage: setup-cachyos.sh <user> <keyd-config-source>
set -euo pipefail

USER_NAME="${1:?missing user}"
KEYD_CONF_SRC="${2:?missing keyd config source}"
KEYD_CONF_DST=/etc/keyd/default.conf
PACKAGES=(keyd alacritty docker docker-compose docker-buildx tailscale)

if ! pacman -Q "${PACKAGES[@]}" >/dev/null 2>&1; then
    echo ">>> cachyos: installing packages (sudo required)"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
fi

if ! cmp -s "$KEYD_CONF_SRC" "$KEYD_CONF_DST"; then
    echo ">>> cachyos: updating $KEYD_CONF_DST (sudo required)"
    sudo install -Dm644 "$KEYD_CONF_SRC" "$KEYD_CONF_DST"
    sudo systemctl try-restart keyd 2>/dev/null || true
fi

# Takes effect in new login sessions.
if ! id -nG "$USER_NAME" | tr ' ' '\n' | grep -qx docker; then
    echo ">>> cachyos: adding $USER_NAME to the docker group (sudo required)"
    sudo usermod -aG docker "$USER_NAME"
fi

[ -d /run/systemd/system ] || exit 0

for svc in keyd docker tailscaled; do
    if ! systemctl is-enabled --quiet "$svc" || ! systemctl is-active --quiet "$svc"; then
        echo ">>> cachyos: enabling and starting $svc (sudo required)"
        sudo systemctl enable --now "$svc"
    fi
done

# Lets the user run `tailscale ...` without sudo. Per profile: set it again
# after `tailscale login` adds a profile.
if [[ "$(tailscale debug prefs 2>/dev/null)" != *"\"OperatorUser\": \"$USER_NAME\""* ]]; then
    echo ">>> cachyos: setting the tailscale operator (sudo required)"
    sudo tailscale set --operator="$USER_NAME"
fi
