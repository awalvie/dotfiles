#!/usr/bin/env bash
# Test for niri-which-key.py: the menu built from the real niri binds.
set -uo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
out=$(python3 -I "$repo/scripts/niri-which-key.py" "$repo/config/niri/cfg/keybinds.kdl") || {
    echo "FAIL: generator failed"
    exit 1
}
fails=0
check() {
    if jq -e "$2" <<<"$out" >/dev/null; then echo "PASS: $1"; else
        echo "FAIL: $1"
        fails=$((fails + 1))
    fi
}
check "every bind is an entry that runs its action" \
    '[.menu[].submenu[] | select(.desc | test("Mod\\+H$"))][0].cmd == "niri msg action focus-column-left"'
check "entries take their bind's own key" \
    '[.menu[] | select(.key == "f") | .submenu[] | select(.cmd | endswith("focus-column-left"))][0].key == "h"'
check "keys are unique within each menu" \
    'all(.menu[]; [.submenu[].key] | length == (unique | length))'
check "spawn binds run their command" \
    'any(.menu[].submenu[]; .cmd == "alacritty")'
check "the menu does not list itself" \
    'all(.menu[].submenu[]; .cmd != "wlr-which-key")'
check "extras are included" \
    'any(.menu[].submenu[]; .cmd == "theme toggle")'
if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else
    echo "$fails FAILED"
    exit 1
fi
