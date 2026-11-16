#!/usr/bin/env bash
# Take a fresh clone to a working host: install nix if missing, enable flakes,
# run the first home-manager switch. Usage: ./bootstrap.sh [pop|cachyos|darwin|--detect]
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

detect_host() {
    if [ "$(uname -s)" = Darwin ]; then
        echo darwin
    elif command -v pacman >/dev/null 2>&1; then
        echo cachyos
    elif command -v apt-get >/dev/null 2>&1; then
        echo pop
    else
        echo "bootstrap: cannot detect host, pass pop, cachyos or darwin" >&2
        return 1
    fi
}

case "${1:-}" in
    --detect)
        detect_host
        exit
        ;;
    "") host=$(detect_host) ;;
    *) host=$1 ;;
esac
echo "bootstrap: host $host"

nix_profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if command -v nix >/dev/null 2>&1 || [ -e "$nix_profile" ]; then
    echo "bootstrap: nix already installed, skipping"
else
    echo "bootstrap: installing nix"
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fi
# A fresh install is not on PATH in this shell yet.
if ! command -v nix >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    . "$nix_profile"
fi

nix_conf=$HOME/.config/nix/nix.conf
if [ -e "$nix_conf" ] || [ -L "$nix_conf" ]; then
    echo "bootstrap: nix.conf already exists, skipping"
else
    mkdir -p "$(dirname "$nix_conf")"
    echo 'experimental-features = nix-command flakes' >"$nix_conf"
fi

nix run home-manager/master -- switch -b backup --flake "$repo#$host" --impure

cat <<'MSG'

bootstrap: done. Remaining manual steps:
  - log out and back in so the session picks up the new shell and environment
  - tailscale up   (once, if this host uses tailscale)
  - on cachyos, do the post-install desktop checks listed in CLAUDE.md
MSG
