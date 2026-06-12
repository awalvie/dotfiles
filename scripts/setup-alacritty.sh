#!/usr/bin/env bash
# Install a desktop entry for the nix-store alacritty on the current host.
# No sudo: writes into ~/.local/share/applications.
#
# nixpkgs' Alacritty.desktop uses bare `Exec=alacritty` / `Icon=Alacritty`,
# which a non-NixOS desktop (COSMIC here) won't resolve because the nix profile
# isn't on the session PATH / icon theme path. We rewrite those to absolute
# store paths so the launcher works regardless.
#
# Usage: setup-alacritty.sh <alacritty-store-prefix>

set -euo pipefail

ALACRITTY_PREFIX="${1:?missing alacritty store prefix}"

DESKTOP_SRC="$ALACRITTY_PREFIX/share/applications/Alacritty.desktop"
ALACRITTY_BIN="$ALACRITTY_PREFIX/bin/alacritty"
ICON="$ALACRITTY_PREFIX/share/icons/hicolor/scalable/apps/Alacritty.svg"

DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_DST="$DESKTOP_DIR/Alacritty.desktop"
DESKTOP_TMP=$(mktemp)
trap 'rm -f "$DESKTOP_TMP"' EXIT

# Rewrite the bare names to absolute store paths.
sed \
    -e "s|^TryExec=alacritty$|TryExec=${ALACRITTY_BIN}|" \
    -e "s|^Exec=alacritty$|Exec=${ALACRITTY_BIN}|" \
    -e "s|^Icon=Alacritty$|Icon=${ICON}|" \
    "$DESKTOP_SRC" > "$DESKTOP_TMP"

if [ ! -f "$DESKTOP_DST" ] || ! cmp -s "$DESKTOP_TMP" "$DESKTOP_DST"; then
    echo ">>> alacritty: installing desktop entry"
    install -Dm644 "$DESKTOP_TMP" "$DESKTOP_DST"
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    fi
    echo ">>> alacritty: desktop entry ready"
else
    echo ">>> alacritty: desktop entry already up to date"
fi
