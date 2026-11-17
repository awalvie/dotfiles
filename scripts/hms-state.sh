#!/usr/bin/env bash
# Tracks which repo state `hms` last applied.
#   hms-state.sh record   store the repo's current state (run by activation)
#   hms-state.sh check    exit 0 if the repo differs from the applied state
# The state is the HEAD commit plus a checksum of the uncommitted tracked
# changes. Local only: no network, two git calls.
set -u
repo=${DOTFILES_REPO:-$HOME/dotfiles}
file=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/applied

state() {
  local head diff
  head=$(git -C "$repo" rev-parse HEAD 2>/dev/null) || return 1
  diff=$(git -C "$repo" diff HEAD 2>/dev/null | cksum)
  echo "$head $diff"
}

case ${1:-} in
  record)
    now=$(state) || exit 0
    mkdir -p "${file%/*}"
    echo "$now" >"$file"
    ;;
  check)
    now=$(state) || exit 1 # no repo: nothing to be behind
    [ "$now" != "$(cat "$file" 2>/dev/null)" ]
    ;;
  *)
    echo "usage: ${0##*/} record|check" >&2
    exit 2
    ;;
esac
