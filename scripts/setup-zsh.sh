#!/usr/bin/env bash
# Make the nix-managed zsh the login shell on a non-NixOS host. Needs sudo
# (appends to /etc/shells, runs chsh). Idempotent.
#
# Uses the stable ~/.nix-profile/bin/zsh symlink (survives store GC and
# rebuilds), NOT a raw /nix/store path, so it doesn't churn /etc/shells or
# re-chsh on every update.
#
# Usage: setup-zsh.sh <zsh-login-path> <user>

set -euo pipefail

ZSH_BIN="${1:?missing zsh path}"
TARGET_USER="${2:?missing user}"

current=$(getent passwd "$TARGET_USER" | cut -d: -f7 || true)

if [ "$current" = "$ZSH_BIN" ]; then
    echo ">>> zsh: already the login shell"
    exit 0
fi

echo ">>> zsh: setting login shell to $ZSH_BIN (sudo required)"

# chsh refuses a shell that isn't listed in /etc/shells; add it first.
if ! grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
fi

sudo chsh -s "$ZSH_BIN" "$TARGET_USER"
echo ">>> zsh: login shell set (log out and back in to take effect)"
