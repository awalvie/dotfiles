#!/usr/bin/env bash
# CachyOS setup that Nix can't manage (root daemons, /etc, group membership).
# Installs keyd, Alacritty, Docker (+ compose, buildx) and Tailscale from the
# Arch repos in one pacman call, installs the repo's keyd config, enables keyd,
# docker and tailscaled with their shipped units, adds the user to the docker
# group and makes the user the Tailscale operator. Idempotent: sudo only when
# something has to change, quiet when nothing did. Service steps only run on a
# booted systemd host. Does NOT log in: run `tailscale up` once by hand.
# Called by home-manager activation OR runnable standalone.
#
# Usage: setup-cachyos.sh <user> <keyd-config-source>

set -euo pipefail

USER_NAME="${1:?missing user}"
KEYD_CONF_SRC="${2:?missing keyd config source}"

KEYD_CONF_DST=/etc/keyd/default.conf
PACKAGES=(keyd alacritty docker docker-compose docker-buildx tailscale)
SERVICES=(keyd docker tailscaled)
changed=0

missing=()
for pkg in "${PACKAGES[@]}"; do
    pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done
if [ "${#missing[@]}" -gt 0 ]; then
    echo ">>> cachyos: installing ${missing[*]} (sudo required)"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
    changed=1
fi

if ! cmp -s "$KEYD_CONF_SRC" "$KEYD_CONF_DST"; then
    echo ">>> cachyos: updating $KEYD_CONF_DST (sudo required)"
    sudo install -Dm644 "$KEYD_CONF_SRC" "$KEYD_CONF_DST"
    sudo systemctl try-restart keyd 2>/dev/null || true
    changed=1
fi

# The docker package's sysusers hook creates the group; the user only gains it
# in new login sessions.
if ! id -nG "$USER_NAME" | tr ' ' '\n' | grep -qx docker; then
    echo ">>> cachyos: adding $USER_NAME to the docker group (re-login to take effect)"
    sudo usermod -aG docker "$USER_NAME"
    changed=1
fi

if [ -d /run/systemd/system ]; then
    for svc in "${SERVICES[@]}"; do
        if ! systemctl is-enabled --quiet "$svc" || ! systemctl is-active --quiet "$svc"; then
            echo ">>> cachyos: enabling and starting $svc (sudo required)"
            sudo systemctl enable --now "$svc"
            changed=1
        fi
    done

    # Lets the user run `tailscale up/serve/...` without sudo. The operator is a
    # per-profile pref: set it again after `tailscale login` adds a profile.
    if systemctl is-active --quiet tailscaled; then
        prefs="$(tailscale debug prefs 2>/dev/null || true)"
        if [[ "$prefs" != *"\"OperatorUser\": \"$USER_NAME\""* ]]; then
            echo ">>> cachyos: setting the tailscale operator (sudo required)"
            sudo tailscale set --operator="$USER_NAME"
            changed=1
        fi
    fi
fi

[ "$changed" -eq 0 ] || echo ">>> cachyos: ready (log in to tailscale once with: tailscale up)"
