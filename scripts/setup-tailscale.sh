#!/usr/bin/env bash
# Tailscale setup that Nix can't manage on a non-NixOS host (root daemon,
# systemd unit, apt repo). Installs Tailscale from its official apt repo,
# enables tailscaled, and makes the user the operator (tailscale CLI without
# sudo). Idempotent: no sudo once tailscaled runs and the user is the operator.
# Does NOT log in: run `tailscale up` once by hand (opens a browser).
# Called by home-manager activation OR runnable standalone.
#
# Usage: setup-tailscale.sh <user>

set -euo pipefail

USER_NAME="${1:?missing user}"

TS_KEY=/usr/share/keyrings/tailscale-archive-keyring.gpg
TS_LIST=/etc/apt/sources.list.d/tailscale.list

install_tailscale() {
    echo ">>> tailscale: installing from Tailscale's official apt repo (sudo required)"

    sudo apt-get update -qq
    sudo apt-get install -y -qq ca-certificates curl

    # PopOS is Ubuntu-based; UBUNTU_CODENAME maps to a release Tailscale publishes.
    local codename
    codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
    sudo curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${codename}.noarmor.gpg" -o "$TS_KEY"
    sudo curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${codename}.tailscale-keyring.list" -o "$TS_LIST"

    sudo apt-get update -qq
    sudo apt-get install -y -qq tailscale

    sudo systemctl enable --now tailscaled
}

if command -v tailscale >/dev/null && systemctl is-active --quiet tailscaled; then
    echo ">>> tailscale: already installed and running"
else
    install_tailscale
fi

# Lets the user run `tailscale up/serve/switch/...` without sudo. The operator is
# a per-profile pref: set it again after `tailscale login` adds a profile.
# Only prompts for sudo when it is missing.
prefs="$(tailscale debug prefs 2>/dev/null || true)"
if [[ "$prefs" != *"\"OperatorUser\": \"$USER_NAME\""* ]]; then
    sudo tailscale set --operator="$USER_NAME"
fi
echo ">>> tailscale: ready (log in once with: tailscale up)"
