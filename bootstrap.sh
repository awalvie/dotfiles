#!/usr/bin/env bash
# Take a fresh clone to a working host: install nix if missing, enable flakes,
# run the first home-manager switch. Usage: ./bootstrap.sh [pop|cachyos|darwin]
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

host=${1:-}
if [ -z "$host" ]; then
    if [ "$(uname -s)" = Darwin ]; then host=darwin
    elif command -v pacman >/dev/null; then host=cachyos
    elif command -v apt-get >/dev/null; then host=pop
    else echo "bootstrap: cannot detect host, pass pop, cachyos or darwin" >&2; exit 1
    fi
fi
echo "bootstrap: host $host"

nix_profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if command -v nix >/dev/null || [ -e "$nix_profile" ]; then
    echo "bootstrap: nix already installed, skipping"
else
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fi
# A fresh install is not on PATH in this shell yet.
# shellcheck disable=SC1090
command -v nix >/dev/null || . "$nix_profile"

nix_conf=$HOME/.config/nix/nix.conf
if [ -e "$nix_conf" ] || [ -L "$nix_conf" ]; then
    echo "bootstrap: nix.conf already exists, skipping"
else
    mkdir -p "$(dirname "$nix_conf")"
    echo 'experimental-features = nix-command flakes' >"$nix_conf"
fi

nix run home-manager/master -- switch -b backup --flake "$repo#$host" --impure

echo "bootstrap: done. Log out and in again, run 'tailscale up' once, and on cachyos do the checks in CLAUDE.md."
