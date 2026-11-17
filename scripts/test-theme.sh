#!/usr/bin/env bash
# Tests for the `theme` command against a temporary home. No real config is touched.
set -uo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
theme=$repo/home/bin/theme
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home
# a fake pkill records the signal instead of reaching a real btop
mkdir -p "$tmp/bin"
printf '#!/bin/sh\necho "$@" >> "%s/pkill.log"\n' "$tmp" > "$tmp/bin/pkill"
chmod +x "$tmp/bin/pkill"
export PATH=$tmp/bin:$PATH
unset XDG_STATE_HOME XDG_CONFIG_HOME XDG_CURRENT_DESKTOP
mkdir -p "$HOME/.config"
# A private runtime dir and a fake nvim keep real nvim instances out of reach.
export XDG_RUNTIME_DIR=$tmp/run
export NVIM_LOG=$tmp/nvim.log
mkdir -p "$XDG_RUNTIME_DIR" "$tmp/bin"
cat >"$tmp/bin/nvim" <<'F'
#!/usr/bin/env bash
echo "$*" >>"$NVIM_LOG"
F
chmod +x "$tmp/bin/nvim"
export PATH=$tmp/bin:$PATH
ln -s "$repo/config/themes" "$HOME/.config/themes"
current=$HOME/.local/state/theme/current

# A fake tmux that records its arguments, ahead of any real one.
mkdir -p "$tmp/bin"
printf '#!/bin/sh\necho "$@" >> "%s/tmux.calls"\n' "$tmp" >"$tmp/bin/tmux"
chmod +x "$tmp/bin/tmux"
export PATH=$tmp/bin:$PATH

fails=0
check() {
    local desc=$1
    shift
    if "$@" >/dev/null 2>&1; then echo "PASS: $desc"; else
        echo "FAIL: $desc"
        fails=$((fails + 1))
    fi
}
resolves_to() { [ "$(readlink -f "$current")" = "$(readlink -f "$HOME/.config/themes/$1")" ]; }
has_text() { grep -q "$2" "$1"; }
has_line() { grep -qxF -e "$2" "$1"; }
newer_than() { [ "$1" -nt "$2" ]; }

# init creates the default link only when it is missing
"$theme" init
check "init links rose-pine moon by default" resolves_to rose-pine/moon
"$theme" apply light
"$theme" init
check "init keeps an existing link" resolves_to rose-pine/dawn

# apply moves the link, and the alacritty colours resolve through it
"$theme" apply dark
check "apply dark links moon" resolves_to rose-pine/moon
check "alacritty colours resolve for moon" has_text "$current/alacritty.toml" '#232136'
check "moon variant is marked dark" has_text "$current/mode" '^dark$'

# apply reloads alacritty by touching the file it watches
old=$(readlink -f "$current/alacritty.toml")
touch -d '2000-01-01' "$old"
ref=$tmp/ref
touch -d '2001-01-01' "$ref"
"$theme" apply light
check "apply light links dawn" resolves_to rose-pine/dawn
check "alacritty colours resolve for dawn" has_text "$current/alacritty.toml" '#faf4ed'
check "apply light marks light" has_text "$current/mode" '^light$'
check "apply touches the previously watched alacritty file" newer_than "$old" "$ref"

# btop and sofka files come from the variant; btop is signalled to reload
check "btop colours resolve for dawn" has_text "$current/btop.theme" '#faf4ed'
check "sofka skin resolves for dawn" has_text "$current/sofka.toml" 'rose-pine-dawn'
check "apply signals btop to reload its theme" has_text "$tmp/pkill.log" '^-USR2 -x btop$'
check "delta flag resolves for dawn" has_text "$current/delta.gitconfig" 'light = true'
"$theme" apply dark
check "delta flag resolves for moon" has_text "$current/delta.gitconfig" 'dark = true'
check "btop colours resolve for moon" has_text "$current/btop.theme" '#232136'
check "sofka moon keeps its colour overrides" has_text "$current/sofka.toml" '#56526e'

# alacritty's config imports its colours through the stable path
# shellcheck disable=SC2088
check "alacritty.toml imports through the current link" \
    grep -qF '~/.local/state/theme/current/alacritty.toml' "$repo/config/alacritty/alacritty.toml"

# set records the theme and applies its variant for the current mode;
# a one-variant theme is used in both modes
fx=$tmp/themes
mkdir -p "$fx/solo/only"
echo 'dark=only' >"$fx/solo/theme"
echo dark >"$fx/solo/only/mode"
ln -s "$repo/config/themes/rose-pine" "$fx/rose-pine"
fixture_theme() { THEME_DIR=$fx "$theme" "$@"; }
fixture_resolves_to() { [ "$(readlink -f "$current")" = "$(readlink -f "$fx/$1")" ]; }
fixture_theme apply light
fixture_theme set solo
check "set applies the one-variant theme in light mode" fixture_resolves_to solo/only
check "set records the theme name" has_text "$HOME/.local/state/theme/name" '^solo$'
fixture_theme apply dark
check "one-variant theme is used in dark mode too" fixture_resolves_to solo/only
fixture_theme set rose-pine
check "set keeps the current mode when changing theme" fixture_resolves_to rose-pine/moon
rejects_unknown_theme() { ! fixture_theme set nope; }
check "set rejects an unknown theme" rejects_unknown_theme
check "a rejected set keeps the recorded theme" has_text "$HOME/.local/state/theme/name" '^rose-pine$'

# tmux colours come from the variant, and a switch reloads running tmux
check "moon tmux colours resolve" has_text "$repo/config/themes/rose-pine/moon/tmux.conf" '#232136'
check "dawn tmux colours resolve" has_text "$repo/config/themes/rose-pine/dawn/tmux.conf" '#faf4ed'
no_hex() { ! grep -q '#[0-9a-fA-F]\{6\}' "$repo/home/.tmux.conf"; }
check "tmux.conf holds no hex colours" no_hex
check "tmux.conf sources the current link" \
    grep -qF 'source-file -q ~/.local/state/theme/current/tmux.conf' "$repo/home/.tmux.conf"
: >"$tmp/tmux.calls"
"$theme" apply dark
check "apply reloads tmux from the new variant" \
    grep -qF "source-file -q $HOME/.local/state/theme/current/tmux.conf" "$tmp/tmux.calls"

# each variant names its nvim colour scheme
"$theme" apply dark
check "moon names its nvim colour scheme" has_text "$current/nvim" '^rose-pine-moon$'

# apply switches every running nvim through its socket
touch "$XDG_RUNTIME_DIR/nvim.111.0" "$XDG_RUNTIME_DIR/nvim.222.0" "$XDG_RUNTIME_DIR/other.sock"
: >"$NVIM_LOG"
"$theme" apply light
check "apply sends dawn to the first nvim socket" \
    has_line "$NVIM_LOG" "--server $XDG_RUNTIME_DIR/nvim.111.0 --remote-expr execute('colorscheme rose-pine-dawn')"
check "apply sends dawn to the second nvim socket" \
    has_line "$NVIM_LOG" "--server $XDG_RUNTIME_DIR/nvim.222.0 --remote-expr execute('colorscheme rose-pine-dawn')"
only_nvim_sockets() { [ "$(wc -l <"$NVIM_LOG")" -eq 2 ]; }
check "apply ignores other files in the runtime dir" only_nvim_sockets
rm -f "$XDG_RUNTIME_DIR"/nvim.*
check "apply works with no nvim running" "$theme" apply dark

# nvim reads the name from the current link at startup
check "nvim config reads the theme's colour scheme" \
    grep -qF 'theme/current/nvim' "$repo/config/nvim/lua/plugins/rose-pine.lua"

# With Noctalia present, it is the desktop: its mode is read, and toggle flips it
# without moving the link.
cat >"$tmp/bin/noctalia" <<'F'
#!/usr/bin/env bash
echo "$*" >>"$NOCTALIA_LOG"
[ "$*" = "msg theme-mode-get" ] && cat "$NOCTALIA_MODE"
exit 0
F
chmod +x "$tmp/bin/noctalia"
export NOCTALIA_LOG=$tmp/noctalia.log NOCTALIA_MODE=$tmp/noctalia.mode
: >"$NOCTALIA_LOG"
rm -rf "$HOME/.local/state/theme"
echo light >"$NOCTALIA_MODE"
"$theme" init
check "init follows Noctalia's mode" resolves_to rose-pine/dawn
"$theme" apply dark
rm "$current"
echo light >"$NOCTALIA_MODE"
fixture_theme set rose-pine
check "set reads Noctalia's mode when no variant is applied" fixture_resolves_to rose-pine/dawn
"$theme" apply dark
: >"$NOCTALIA_LOG"
"$theme" toggle
check "toggle asks Noctalia to flip its mode" has_line "$NOCTALIA_LOG" "msg theme-mode-toggle"
check "toggle leaves the link to the hook" resolves_to rose-pine/moon
# shellcheck disable=SC2016
check "noctalia hook applies the mode" \
    grep -qF 'theme apply $NOCTALIA_THEME_MODE' "$repo/config/noctalia/theme-hook.toml"
rm "$tmp/bin/noctalia"

# the work PC desktop: one Noctalia palette per theme (dark and light), niri
# colours per variant
pal=$repo/config/themes/rose-pine/noctalia.json
check "Noctalia palette has dark and light" jq -e '.dark.primary and .light.primary' "$pal"
check "Noctalia light palette uses the dawn base" has_text "$pal" '#faf4ed'
for v in moon dawn; do
    check "$v has niri border colours" has_text "$repo/config/themes/rose-pine/$v/niri.kdl" 'focus-ring'
done
check "moon niri colours use the moon gold" has_text "$repo/config/themes/rose-pine/moon/niri.kdl" '#f6c177'
check "Noctalia's palette links to the theme's palette" \
    test "$(readlink -f "$repo/config/noctalia/palettes/RosePine.json")" = "$(readlink -f "$pal")"
check "Noctalia config selects the custom palette" has_text "$repo/config/noctalia/config.toml" 'custom_palette *= *"RosePine"'
check "niri includes colours through the current link" \
    grep -qF 'include optional=true "~/.local/state/theme/current/niri.kdl"' "$repo/config/niri/config.kdl"

# on COSMIC the mode reader follows the desktop's is_dark file
export XDG_CURRENT_DESKTOP=COSMIC
cosmic_dark=$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark
mkdir -p "$(dirname "$cosmic_dark")"
rm -rf "$HOME/.local/state/theme"
echo false >"$cosmic_dark"
"$theme" init
check "init follows a light COSMIC" resolves_to rose-pine/dawn
rm -rf "$HOME/.local/state/theme"
echo true >"$cosmic_dark"
"$theme" init
check "init follows a dark COSMIC" resolves_to rose-pine/moon

# toggle flips COSMIC's setting and leaves the link to the watcher
"$theme" toggle
check "toggle flips COSMIC to light" has_line "$cosmic_dark" false
check "toggle does not move the link" resolves_to rose-pine/moon
"$theme" toggle
check "toggle flips COSMIC back to dark" has_line "$cosmic_dark" true

# the watcher turns portal colour-scheme signals into theme apply
signal() {
    echo "/org/freedesktop/portal/desktop: org.freedesktop.portal.Settings.SettingChanged ('$1', '$2', <$3>)"
}
signal org.freedesktop.appearance color-scheme 'uint32 2' | "$repo/home/bin/theme-watch"
check "watcher applies light on colour-scheme 2" resolves_to rose-pine/dawn
signal org.freedesktop.appearance color-scheme 'uint32 1' | "$repo/home/bin/theme-watch"
check "watcher applies dark on colour-scheme 1" resolves_to rose-pine/moon
{
    signal org.gnome.desktop color-scheme 'uint32 2'
    signal org.freedesktop.appearance accent-color '(0.1, 0.2, 0.3)'
} | "$repo/home/bin/theme-watch"
check "watcher ignores other settings" resolves_to rose-pine/moon
unset XDG_CURRENT_DESKTOP

rejects_unknown_mode() { ! "$theme" apply purple; }
check "apply rejects an unknown mode" rejects_unknown_mode

# discoverability: status, list and help
check "theme with no arguments shows the theme" bash -c '"$0" | grep -q "^theme: *rose-pine"' "$theme"
check "theme list marks the current theme" bash -c '"$0" list | grep -q "^\* rose-pine .*dark: moon .*light: dawn"' "$theme"
check "theme help lists the commands" bash -c '"$0" help | grep -q "theme toggle"' "$theme"
check "an unknown command prints the help" bash -c '"$0" bogus 2>&1 | grep -q "theme list"' "$theme"

if [ "$fails" -eq 0 ]; then echo "ALL PASS"; else
    echo "$fails FAILED"
    exit 1
fi
