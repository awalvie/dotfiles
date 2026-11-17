#!/usr/bin/env bash
# CachyOS setup that nix can't manage: pacman packages, /etc/keyd, the login
# screen (greetd + ReGreet in niri), services, the docker group and the
# Tailscale operator. Idempotent: sudo only when
# something has to change. Service steps only run on a booted systemd host.
# Login stays manual: run `tailscale up` once.
#
# Usage: setup-cachyos.sh <user> <keyd-config> <greetd-dir> <niri-cfg-dir> <wallpapers-dir>
#   <greetd-dir> holds the greetd, greeter niri and ReGreet configs; the
#   greeter reuses display.kdl and input.kdl from <niri-cfg-dir>.
#   <wallpapers-dir> holds {dark,light}/{wide,tall}/ paintings, installed to
#   /usr/share/backgrounds/dotfiles for Noctalia and the login screen.
set -euo pipefail

USER_NAME="${1:?missing user}"
KEYD_CONF_SRC="${2:?missing keyd config source}"
KEYD_CONF_DST=/etc/keyd/default.conf
GREETD_SRC="${3:?missing greetd dir}"
NIRI_CFG="${4:?missing niri cfg dir}"
WALLPAPERS_SRC="${5:?missing wallpapers dir}"
WALLPAPERS_DST=/usr/share/backgrounds/dotfiles
PACKAGES=(keyd alacritty docker docker-compose docker-buildx tailscale
    greetd greetd-regreet)

if ! pacman -Q "${PACKAGES[@]}" >/dev/null 2>&1; then
    echo ">>> cachyos: installing packages (sudo required)"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
fi

if ! cmp -s "$KEYD_CONF_SRC" "$KEYD_CONF_DST"; then
    echo ">>> cachyos: updating $KEYD_CONF_DST (sudo required)"
    sudo install -Dm644 "$KEYD_CONF_SRC" "$KEYD_CONF_DST"
    sudo systemctl try-restart keyd 2>/dev/null || true
fi

# Login screen: greetd runs ReGreet inside niri with the desktop's screen
# layout. The greeter user cannot read the home folder, so everything goes
# into /etc/greetd (read at the next login screen).
login_files=(
    "$GREETD_SRC/config.toml:/etc/greetd/config.toml"
    "$GREETD_SRC/niri.kdl:/etc/greetd/niri.kdl"
    "$GREETD_SRC/regreet.toml:/etc/greetd/regreet.toml"
    "$GREETD_SRC/regreet.css:/etc/greetd/regreet.css"
    "$GREETD_SRC/regreet-tmpfiles.conf:/etc/tmpfiles.d/regreet.conf"
    "$NIRI_CFG/display.kdl:/etc/greetd/display.kdl"
    "$NIRI_CFG/input.kdl:/etc/greetd/input.kdl"
)
for pair in "${login_files[@]}"; do
    src=${pair%%:*} dst=${pair#*:}
    if ! cmp -s "$src" "$dst"; then
        echo ">>> cachyos: updating $dst (sudo required)"
        sudo install -Dm644 "$src" "$dst"
    fi
done

# Wallpapers, readable by every user (the greeter too). Noctalia rotates
# through them; the login screen picks a random dark one.
if ! diff -rq "$WALLPAPERS_SRC" "$WALLPAPERS_DST" >/dev/null 2>&1; then
    echo ">>> cachyos: updating $WALLPAPERS_DST (sudo required)"
    sudo rm -rf "$WALLPAPERS_DST"
    sudo mkdir -p "$(dirname "$WALLPAPERS_DST")"
    sudo cp -r "$WALLPAPERS_SRC" "$WALLPAPERS_DST"
    sudo chmod -R a+rX "$WALLPAPERS_DST"
fi

# Takes effect in new login sessions.
if ! id -nG "$USER_NAME" | tr ' ' '\n' | grep -qx docker; then
    echo ">>> cachyos: adding $USER_NAME to the docker group (sudo required)"
    sudo usermod -aG docker "$USER_NAME"
fi

[ -d /run/systemd/system ] || exit 0

[ -d /var/lib/regreet ] || sudo systemd-tmpfiles --create /etc/tmpfiles.d/regreet.conf

# Switch the login screen from SDDM to greetd. Only enabled, not started:
# it takes over at the next boot.
if ! systemctl is-enabled --quiet greetd; then
    echo ">>> cachyos: switching the login screen to greetd at next boot (sudo required)"
    sudo systemctl disable sddm 2>/dev/null || true
    sudo systemctl enable greetd
fi

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
