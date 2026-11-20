#!/usr/bin/env bash
# CachyOS setup that nix can't manage: pacman packages, /etc/keyd, the login
# screen (greetd + tuigreet), services, SSH from the LAN, the docker
# group and the Tailscale operator. Idempotent: sudo only when
# something has to change. Service steps only run on a booted systemd host.
# Login stays manual: run `tailscale up` once.
#
# Usage: setup-cachyos.sh <user> <keyd-config> <greetd-config> <wallpapers-dir>
#   <wallpapers-dir> holds {dark,light}/{wide,tall}/ paintings, installed to
#   /usr/share/backgrounds/dotfiles for Noctalia.
set -euo pipefail

USER_NAME="${1:?missing user}"
KEYD_CONF_SRC="${2:?missing keyd config source}"
KEYD_CONF_DST=/etc/keyd/default.conf
GREETD_CONF_SRC="${3:?missing greetd config}"
GREETD_CONF_DST=/etc/greetd/config.toml
WALLPAPERS_SRC="${4:?missing wallpapers dir}"
WALLPAPERS_DST=/usr/share/backgrounds/dotfiles
PACKAGES=(keyd alacritty docker docker-compose docker-buildx tailscale
    greetd greetd-tuigreet flatpak openssh wf-recorder slurp)

if ! pacman -Q "${PACKAGES[@]}" >/dev/null 2>&1; then
    echo ">>> cachyos: installing packages (sudo required)"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
fi

if ! cmp -s "$KEYD_CONF_SRC" "$KEYD_CONF_DST"; then
    echo ">>> cachyos: updating $KEYD_CONF_DST (sudo required)"
    sudo install -Dm644 "$KEYD_CONF_SRC" "$KEYD_CONF_DST"
    sudo systemctl try-restart keyd 2>/dev/null || true
fi

# Login screen: greetd runs tuigreet (read at the next login screen).
if ! cmp -s "$GREETD_CONF_SRC" "$GREETD_CONF_DST"; then
    echo ">>> cachyos: updating $GREETD_CONF_DST (sudo required)"
    sudo install -Dm644 "$GREETD_CONF_SRC" "$GREETD_CONF_DST"
fi

# Leftovers of the earlier login screen (ReGreet inside niri).
regreet_files=(/etc/greetd/niri.kdl /etc/greetd/regreet.toml /etc/greetd/regreet.css
    /etc/greetd/display.kdl /etc/greetd/input.kdl /etc/tmpfiles.d/regreet.conf /var/lib/regreet)
for f in "${regreet_files[@]}"; do
    if [ -e "$f" ]; then
        echo ">>> cachyos: removing $f, left from ReGreet (sudo required)"
        sudo rm -rf "$f"
    fi
done
if pacman -Q greetd-regreet >/dev/null 2>&1; then
    echo ">>> cachyos: removing greetd-regreet (sudo required)"
    sudo pacman -Rns --noconfirm greetd-regreet
fi

# Wallpapers, readable by every user. Noctalia rotates through them and
# its lock screen shows the current one.
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

# tuigreet --remember writes here; the package may not create it.
if [ ! -d /var/cache/tuigreet ]; then
    echo ">>> cachyos: creating /var/cache/tuigreet (sudo required)"
    sudo install -d -o greeter -g greeter -m 755 /var/cache/tuigreet
fi

# Switch the login screen from SDDM to greetd. Only enabled, not started:
# it takes over at the next boot.
if ! systemctl is-enabled --quiet greetd; then
    echo ">>> cachyos: switching the login screen to greetd at next boot (sudo required)"
    sudo systemctl disable sddm 2>/dev/null || true
    sudo systemctl enable greetd
fi

for svc in keyd docker tailscaled sshd; do
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

# SSH in from the office LAN (ufw drops everything else). sshd keeps Arch's
# defaults: keys and passwords, no root password login.
SSH_LAN=192.168.0.0/20
if command -v ufw >/dev/null &&
    ! grep -qF "### tuple ### allow tcp 22 0.0.0.0/0 any $SSH_LAN in" /etc/ufw/user.rules 2>/dev/null; then
    echo ">>> cachyos: allowing SSH from $SSH_LAN in ufw (sudo required)"
    sudo ufw allow proto tcp from "$SSH_LAN" to any port 22
fi
