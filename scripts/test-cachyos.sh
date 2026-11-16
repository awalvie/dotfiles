#!/usr/bin/env bash
# Container test: bootstrap a fresh clone on CachyOS (cachyos/cachyos image,
# real skel files from cachyos-niri-noctalia). Plain unprivileged docker run:
# no --privileged, no systemd, no host namespaces or mounts.
#
# Not covered: systemd services (nix-daemon runs by hand, the nix installer
# cannot start its unit here), the setup script's enable/start steps, SDDM,
# and the niri desktop itself. Those are manual checks (see CLAUDE.md).
#
# Usage: scripts/test-cachyos.sh [--rebuild]   (--rebuild redoes the cached base image)
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
base_image=dotfiles-test-cachyos-base
ct=dotfiles-test-cachyos-$$
user=tester
home=/home/$user

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
if [ "${1:-}" = "--rebuild" ] || ! docker image inspect "$base_image" >/dev/null 2>&1; then
  echo "building $base_image"
  docker run --name "$ct" cachyos/cachyos bash -euc "
    sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
    pacman -Syu --noconfirm cachyos-niri-noctalia sudo git curl xz
    useradd -m -k /etc/skel -s /bin/bash $user
    echo '$user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$user
  "
  docker commit "$ct" "$base_image" >/dev/null
  cleanup
fi

docker run -d --name "$ct" "$base_image" sleep infinity >/dev/null

# The repo's committed files only.
git -C "$repo" archive --prefix=dotfiles/ HEAD | docker cp - "$ct:$home/"
docker exec "$ct" chown -R "$user:$user" "$home/dotfiles"

# The nix installer cannot start its systemd unit here: start nix-daemon by
# hand as soon as the installer has put it in place.
docker exec -d -e NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt "$ct" bash -c '
  until [ -x /nix/var/nix/profiles/default/bin/nix-daemon ]; do sleep 1; done
  exec /nix/var/nix/profiles/default/bin/nix-daemon'

run_bootstrap() { as_user bash -c "./dotfiles/bootstrap cachyos > $1 2>&1"; }

echo "== first bootstrap run"
if run_bootstrap first.log; then
  pass "first bootstrap run succeeds"
else
  fail "first bootstrap run succeeds"
  as_user tail -n 40 first.log || true
fi
check "alacritty skel config backed up" bash -c 'ls .config/alacritty*.backup .config/alacritty/*.backup'
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

# Add further asserts above this line (setup script, niri desktop checks).
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else echo "$fails FAILED"; exit 1; fi
