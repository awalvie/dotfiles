#!/usr/bin/env bash
# Container test: bootstrap a fresh clone on CachyOS (cachyos/cachyos image,
# real skel files from cachyos-niri-noctalia). Plain unprivileged docker run:
# no --privileged, no systemd, no host namespaces or mounts.
#
# Not covered: systemd services (nix-daemon runs by hand, the nix installer
# cannot start its unit here), the setup script's enable/start steps, SDDM,
# and the niri desktop itself. Those are manual checks (see CLAUDE.md).
#
# Containers are capped (--cpus, --memory). /nix lives in a named volume that
# survives between runs so source builds happen once. A warm volume skips the
# nix installer (the bootstrap sees nix is present), so only a cold run
# (--fresh) exercises it.
#
# Usage: scripts/test-cachyos.sh [--rebuild] [--fresh]
#   --rebuild  redo the cached base image
#   --fresh    delete the /nix volume first (clean run, slow)
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
base_image=dotfiles-test-cachyos-base
nix_volume=dotfiles-test-nix
limits=(--cpus=4 --memory=6g)
ct=dotfiles-test-cachyos-$$
user=tester
home=/home/$user

rebuild=0
for arg in "$@"; do
  case $arg in
    --rebuild) rebuild=1 ;;
    --fresh) docker volume rm -f "$nix_volume" >/dev/null ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

cleanup() { docker rm -f "$ct" >/dev/null 2>&1 || true; }
trap cleanup EXIT

fails=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; fails=$((fails + 1)); }

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
if [ "$rebuild" = 1 ] || ! docker image inspect "$base_image" >/dev/null 2>&1; then
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

# The nix installer cannot start its systemd unit here: start nix-daemon by
# hand as soon as the installer has put it in place.
docker exec -d -e NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt "$ct" bash -c '
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
check "home-manager generation exists" test -e .local/state/nix/profiles/home-manager

echo "== second bootstrap run"
if run_bootstrap second.log; then
  pass "second bootstrap run succeeds"
else
  fail "second bootstrap run succeeds"
  as_user tail -n 40 second.log || true
fi
check "second run skips the nix install" grep -q "nix already installed" second.log
check "second run skips the nix.conf step" grep -q "nix.conf already exists" second.log

echo "== niri desktop"
for d in niri noctalia; do
  check ".config/$d links into the checkout" bash -c "[ \"\$(readlink -f .config/$d)\" = $home/dotfiles/config/$d ]"
done
check "login zsh has ~/.nix-profile/bin on PATH" bash -c "$home/.nix-profile/bin/zsh -l -c 'echo \$PATH' | grep -q '\.nix-profile/bin'"
check "login zsh has nix share in XDG_DATA_DIRS" bash -c "$home/.nix-profile/bin/zsh -l -c 'echo \$XDG_DATA_DIRS' | grep -q '\.nix-profile/share'"
check "safeeyes unit is wanted by graphical-session.target" test -e .config/systemd/user/graphical-session.target.wants/safeeyes.service
check "safeeyes unit exists" test -e .config/systemd/user/safeeyes.service

echo "== setup script"
check "setup script installed the packages" pacman -Q keyd alacritty docker docker-compose docker-buildx tailscale
check "keyd config matches the repo file" cmp dotfiles/home/keyd/default.conf /etc/keyd/default.conf
check "user is in the docker group" bash -c 'id -nG | tr " " "\n" | grep -qx docker'
# Second run by hand with a sudo that always fails: it must not need sudo.
as_user bash -c 'mkdir -p stub && printf "#!/bin/sh\necho sudo called >&2\nexit 1\n" > stub/sudo && chmod +x stub/sudo'
check "second setup run needs no sudo" env PATH="$home/stub:/usr/bin:/bin" \
  dotfiles/scripts/setup-cachyos.sh "$user" "$home/dotfiles/home/keyd/default.conf"
check "cachyos generation has no nix keyd, alacritty or nixGL" bash -c \
  '! grep -rEq "keyd|alacritty-wrapped|nixGL" .local/state/nix/profiles/home-manager/home-path/bin 2>/dev/null'

# Add further asserts above this line (setup script, niri desktop checks).
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else echo "$fails FAILED"; exit 1; fi
