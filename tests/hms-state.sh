#!/usr/bin/env bash
# Tests hms-state.sh against a temporary git repo and a temporary state dir.
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home XDG_STATE_HOME=$tmp/state DOTFILES_REPO=$tmp/repo
mkdir -p "$HOME" "$DOTFILES_REPO"
g() { git -C "$DOTFILES_REPO" -c user.name=t -c user.email=t@t "$@"; }
g init -q
echo a >"$DOTFILES_REPO/f"
g add f
g commit -qm one

fail=0
# check <description> <behind|current>
check() {
  local got=current
  "$here/hms-state.sh" check && got=behind
  if [ "$got" = "$2" ]; then echo "ok   $1"; else echo "FAIL $1 (got $got)"; fail=1; fi
}

check "never applied is behind" behind
"$here/hms-state.sh" record
check "no change" current
echo b >"$DOTFILES_REPO/f"
check "uncommitted edit" behind
"$here/hms-state.sh" record
check "recorded with edit" current
echo c >>"$DOTFILES_REPO/f"
check "further edit while dirty" behind
g commit -qam two
check "new commit" behind
"$here/hms-state.sh" record
check "recorded after commit" current
rm -rf "$DOTFILES_REPO"
check "missing repo shows nothing" current
exit $fail
