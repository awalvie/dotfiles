#!/usr/bin/env bash
# Bootstrap a fresh clone in an unprivileged CachyOS container (no systemd,
# no --privileged). Services, the login screen and the desktop are manual checks.
# /nix is a named volume kept between runs; --fresh deletes it first, which is
# the only way to test the nix installer. To rebuild the base image:
# docker rmi dotfiles-test-cachyos-base
#
# Usage: tests/cachyos.sh [--fresh]
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
base_image=dotfiles-test-cachyos-base
nix_volume=dotfiles-test-nix
limits=(--cpus=4 --memory=6g)
ct=dotfiles-test-cachyos-$$
user=tester
home=/home/$user

case "${1:-}" in
    --fresh) docker volume rm -f "$nix_volume" >/dev/null ;;
    "") ;;
    *) echo "usage: $0 [--fresh]" >&2; exit 2 ;;
esac

cleanup() { docker rm -f "$ct" >/dev/null 2>&1 || true; }
trap cleanup EXIT

fails=0
pass() { echo "PASS: $1"; }
fail() {
    echo "FAIL: $1"
    fails=$((fails + 1))
}

# Run a command in the container as the test user.
as_user() {
    docker exec -u "$user" -e HOME="$home" -e USER="$user" -w "$home" "$ct" "$@"
}
# check "description" cmd...  (cmd runs in the container as the test user)
check() {
    local desc=$1
    shift
    if as_user "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

# Base image: packages + user, built once and cached.
if ! docker image inspect "$base_image" >/dev/null 2>&1; then
    echo "building $base_image"
    docker run "${limits[@]}" --name "$ct" cachyos/cachyos bash -euc "
    sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
    pacman -Syu --noconfirm cachyos-niri-noctalia sudo git curl xz
    useradd -m -k /etc/skel -s /bin/bash $user
    echo '$user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$user
  "
    docker commit "$ct" "$base_image" >/dev/null
    cleanup
fi

docker run -d "${limits[@]}" -v "$nix_volume:/nix" --name "$ct" "$base_image" sleep infinity >/dev/null

# Warm volume: /nix is already populated but this fresh container has no
# nixbld users, which the installer would have created. Recreate them.
if docker exec "$ct" test -e /nix/var/nix/profiles/default/bin/nix-daemon; then
    echo "warm /nix volume: skipping the nix installer, recreating nixbld users"
    docker exec "$ct" bash -euc '
    groupadd -g 30000 nixbld
    for i in $(seq 1 32); do
      useradd -u $((30000 + i)) -g nixbld -G nixbld -M -N -s /usr/bin/nologin "nixbld$i"
    done
    mkdir -p /etc/nix
    echo "build-users-group = nixbld" > /etc/nix/nix.conf'
fi

# The repo's committed files only.
git -C "$repo" archive --prefix=dotfiles/ HEAD | docker cp - "$ct:$home/"
docker exec "$ct" chown -R "$user:$user" "$home/dotfiles"

# No systemd here, so start nix-daemon by hand once it exists. Low parallelism
# keeps builds inside the memory cap (otherwise they get killed).
docker exec -d -e NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    -e NIX_CONFIG=$'max-jobs = 2\ncores = 2' "$ct" bash -c '
  until [ -x /nix/var/nix/profiles/default/bin/nix-daemon ]; do sleep 1; done
  exec /nix/var/nix/profiles/default/bin/nix-daemon'

run_bootstrap() { as_user bash -c "./dotfiles/bootstrap.sh cachyos > $1 2>&1"; }

echo "== first bootstrap run"
if run_bootstrap first.log; then
    pass "first bootstrap run succeeds"
else
    fail "first bootstrap run succeeds"
    as_user tail -n 40 first.log || true
fi
check "alacritty skel config backed up" test -e .config/alacritty/alacritty.toml.backup
check "nix.conf written" grep -q "experimental-features = nix-command flakes" .config/nix/nix.conf

echo "== second bootstrap run"
if run_bootstrap second.log; then
    pass "second bootstrap run succeeds"
else
    fail "second bootstrap run succeeds"
    as_user tail -n 40 second.log || true
fi
check "second run skips the nix install" grep -q "nix already installed" second.log

echo "== niri desktop"
for d in niri noctalia; do
    check ".config/$d links into the checkout" bash -c "[ \"\$(readlink -f .config/$d)\" = $home/dotfiles/config/$d ]"
done
check "login zsh has ~/.nix-profile/bin on PATH" bash -c "$home/.nix-profile/bin/zsh -l -c 'echo \$PATH' | grep -q '\.nix-profile/bin'"
check "login zsh has nix share in XDG_DATA_DIRS" bash -c "$home/.nix-profile/bin/zsh -l -c 'echo \$XDG_DATA_DIRS' | grep -q '\.nix-profile/share'"
check "safeeyes unit is wanted by graphical-session.target" test -e .config/systemd/user/graphical-session.target.wants/safeeyes.service

echo "== theme"
check "default theme link points at a rose-pine variant" bash -c "readlink -f .local/state/theme/current | grep -q '/config/themes/rose-pine/'"
check "alacritty colours resolve through the link" test -s .local/state/theme/current/alacritty.toml
check "tmux colours resolve through the link" test -s .local/state/theme/current/tmux.conf
check "nvim colour scheme resolves through the link" test -s .local/state/theme/current/nvim
check "btop theme resolves through the link" test -s .config/btop/themes/current.theme
check "sofka skin resolves through conf.d" test -s .config/sofka/conf.d/10-theme.toml
check "delta flag resolves through the link" test -s .local/state/theme/current/delta.gitconfig
check "noctalia theme-mode hook runs theme apply" bash -c "grep -q 'theme_mode_changed.*theme apply' .config/noctalia/*.toml"
check "noctalia palette resolves through the link" test -s .config/noctalia/palettes/RosePine.json
check "niri border colours resolve through the link" test -s .local/state/theme/current/niri.kdl
as_user dotfiles/home/bin/theme apply light
as_user bash -c "./dotfiles/bootstrap.sh cachyos > third.log 2>&1"
check "a changed theme link survives another hms" bash -c "readlink -f .local/state/theme/current | grep -q '/rose-pine/dawn\$'"

echo "== setup script"
check "setup script installed the packages" pacman -Q keyd alacritty docker docker-compose docker-buildx tailscale greetd greetd-regreet
check "keyd config matches the repo file" cmp dotfiles/system/keyd/default.conf /etc/keyd/default.conf
check "greetd runs niri for the login screen" grep -q 'niri --config /etc/greetd/niri.kdl' /etc/greetd/config.toml
check "the greeter niri config is valid" niri validate -c /etc/greetd/niri.kdl
check "the login screen uses the desktop's screen layout" cmp dotfiles/config/niri/cfg/display.kdl /etc/greetd/display.kdl
check "regreet uses the rose pine css" grep -q c4a7e7 /etc/greetd/regreet.css
check "the paintings are installed for every screen and mode" bash -c \
    'for d in {dark,light}/{wide,tall}; do ls /usr/share/backgrounds/dotfiles/$d/*.jpg >/dev/null || exit 1; done'
check "the paintings are readable by the greeter" bash -c \
    '[ -z "$(find /usr/share/backgrounds/dotfiles ! -perm -o+r -o -type d ! -perm -o+x)" ]'
check "noctalia wallpaper config is valid" noctalia config validate
check "firefox policy is installed" cmp dotfiles/system/firefox/policies.json /etc/firefox/policies/policies.json
check "user is in the docker group" bash -c 'id -nG | tr " " "\n" | grep -qx docker'
# Second run by hand with a sudo that always fails: it must not need sudo.
as_user bash -c 'mkdir -p stub && printf "#!/bin/sh\necho sudo called >&2\nexit 1\n" > stub/sudo && chmod +x stub/sudo'
check "second setup run needs no sudo" env PATH="$home/stub:/usr/bin:/bin" \
    dotfiles/scripts/setup-cachyos.sh "$user" "$home/dotfiles/system/keyd/default.conf" \
    "$home/dotfiles/system/greetd" "$home/dotfiles/config/niri/cfg" \
    "$home/dotfiles/system/wallpapers"
check "cachyos generation has no nix keyd, alacritty or nixGL" bash -c \
    '! grep -rEq "keyd|alacritty-wrapped|nixGL" .local/state/nix/profiles/home-manager/home-path/bin 2>/dev/null'

if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else
    echo "$fails FAILED"
    exit 1
fi
