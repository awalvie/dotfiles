#!/usr/bin/env bash
# Install the given Flatpak apps for this user, from Flathub.
# Each app brings its own libraries, so the host's packages stay untouched;
# Flatpak also pulls the GL driver extension that matches the host's NVIDIA
# driver. No sudo. Idempotent: only installs what is missing. Does nothing
# when flatpak itself is not installed yet (setup-cachyos.sh installs it).
#
# Usage: setup-flatpak.sh <app-id>...
set -euo pipefail

if ! command -v flatpak >/dev/null; then
    echo ">>> flatpak: not installed yet, skipping (run hms again after it is)"
    exit 0
fi

flatpak remote-add --user --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

missing=()
for app in "$@"; do
    flatpak info --user "$app" >/dev/null 2>&1 || missing+=("$app")
done

# One app at a time, and a failure only warns: a broken app or a Flathub
# outage must not stop the rest of hms. The next hms tries again.
for app in "${missing[@]}"; do
    echo ">>> flatpak: installing $app"
    flatpak install --user --noninteractive flathub "$app" ||
        echo ">>> flatpak: WARNING: $app failed to install; hms carries on" >&2
done
