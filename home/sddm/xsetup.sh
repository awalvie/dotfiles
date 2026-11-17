#!/bin/sh
# Screen layout for the login screen (SDDM on X11 runs this before the
# greeter): the Dell (2560x1440) in portrait on the left, the Samsung
# (3440x1440) as the primary screen to its right, centred on the Dell's
# height, as in niri. X11 output names differ from niri's, so screens are
# found by their resolution. The Samsung is cabled twice: keep a DisplayPort
# output and switch the other off.
modes=$(xrandr --query | awk '/ connected/ { out = $1; next } out && /^ +[0-9]+x[0-9]+/ { print out, $1; out = "" }')
dell=$(echo "$modes" | awk '$2 == "2560x1440" { print $1; exit }')
samsungs=$(echo "$modes" | awk '$2 == "3440x1440" { print $1 }')
samsung=$(echo "$samsungs" | grep '^DP' | head -n1)
[ -n "$samsung" ] || samsung=$(echo "$samsungs" | head -n1)

args=""
[ -n "$dell" ] && args="$args --output $dell --rotate left --pos 0x0"
[ -n "$samsung" ] && args="$args --output $samsung --primary --pos 1440x560"
for other in $samsungs; do
    [ "$other" = "$samsung" ] || args="$args --output $other --off"
done
# shellcheck disable=SC2086
[ -n "$args" ] && xrandr $args
exit 0
