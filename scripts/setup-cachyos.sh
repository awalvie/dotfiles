#!/usr/bin/env bash
# CachyOS setup that nix can't manage: pacman packages, /etc/keyd, the SDDM
# login theme, services, the docker group and the Tailscale operator. Idempotent: sudo only when
# something has to change. Service steps only run on a booted systemd host.
# Login stays manual: run `tailscale up` once.
#
# Usage: setup-cachyos.sh <user> <keyd-config> <sddm-dir> <login-wallpaper>
#   <sddm-dir> holds conf.d/*.conf (for /etc/sddm.conf.d) and the theme config
#   astronaut-rose-pine.conf
set -euo pipefail

USER_NAME="${1:?missing user}"
KEYD_CONF_SRC="${2:?missing keyd config source}"
KEYD_CONF_DST=/etc/keyd/default.conf
SDDM_SRC="${3:?missing sddm dir}"
LOGIN_WALLPAPER="${4:?missing login wallpaper}"
# sddm-astronaut-theme is not packaged in the Arch or CachyOS repos: pin a commit.
THEME_REPO=https://github.com/Keyitdev/sddm-astronaut-theme
THEME_COMMIT=abb3163c724935af888ba5ea9ac0c4f22afd8048
THEME_DST=/usr/share/sddm/themes/sddm-astronaut-theme
PACKAGES=(keyd alacritty docker docker-compose docker-buildx tailscale mpvpaper mpv socat
    qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg xorg-xrandr)

if ! pacman -Q "${PACKAGES[@]}" >/dev/null 2>&1; then
    echo ">>> cachyos: installing packages (sudo required)"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
fi

if ! cmp -s "$KEYD_CONF_SRC" "$KEYD_CONF_DST"; then
    echo ">>> cachyos: updating $KEYD_CONF_DST (sudo required)"
    sudo install -Dm644 "$KEYD_CONF_SRC" "$KEYD_CONF_DST"
    sudo systemctl try-restart keyd 2>/dev/null || true
fi

# Login screen, read by SDDM at its next start. The theme is fetched at the
# pinned commit; our config and wallpaper go inside it (SDDM runs as its own
# user and cannot read the home folder).
for src in "$SDDM_SRC"/conf.d/*.conf; do
    dst=/etc/sddm.conf.d/$(basename "$src")
    if ! cmp -s "$src" "$dst"; then
        echo ">>> cachyos: updating $dst (sudo required)"
        sudo install -Dm644 "$src" "$dst"
    fi
done
if [ "$(cat "$THEME_DST/.commit" 2>/dev/null)" != "$THEME_COMMIT" ]; then
    echo ">>> cachyos: installing the login theme (sudo required)"
    tmp=$(mktemp -d)
    git -C "$tmp" init -q
    git -C "$tmp" fetch -q --depth 1 "$THEME_REPO" "$THEME_COMMIT"
    git -C "$tmp" checkout -q FETCH_HEAD
    rm -rf "$tmp/.git"
    echo "$THEME_COMMIT" >"$tmp/.commit"
    sudo rm -rf "$THEME_DST"
    sudo mkdir -p "$(dirname "$THEME_DST")"
    sudo cp -r "$tmp" "$THEME_DST"
    sudo chmod -R a+rX "$THEME_DST"
    rm -rf "$tmp"
fi
theme_files=(
    "$SDDM_SRC/astronaut-rose-pine.conf:$THEME_DST/Themes/rose-pine.conf"
    "$LOGIN_WALLPAPER:$THEME_DST/Backgrounds/login.gif"
)
for pair in "${theme_files[@]}"; do
    src=${pair%%:*} dst=${pair#*:}
    if ! cmp -s "$src" "$dst"; then
        echo ">>> cachyos: updating $dst (sudo required)"
        sudo install -Dm644 "$src" "$dst"
    fi
done
if ! cmp -s "$SDDM_SRC/xsetup.sh" /etc/sddm/xsetup.sh; then
    echo ">>> cachyos: updating /etc/sddm/xsetup.sh (sudo required)"
    sudo install -Dm755 "$SDDM_SRC/xsetup.sh" /etc/sddm/xsetup.sh
fi
if ! grep -qx 'ConfigFile=Themes/rose-pine.conf' "$THEME_DST/metadata.desktop"; then
    echo ">>> cachyos: selecting the Rosé Pine login config (sudo required)"
    sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/rose-pine.conf|' "$THEME_DST/metadata.desktop"
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
