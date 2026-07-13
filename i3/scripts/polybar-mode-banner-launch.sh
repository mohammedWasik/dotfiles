#!/bin/bash
# Launch the mode-banner polybar bar(s). Called by polybar-mode-watch when
# entering any non-default i3 mode; killed when returning to default.

is_active() {
    xrandr | grep "^$1 connected" | grep -qE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+'
}

if is_active DP-2; then
    polybar secondary-mode-banner > /tmp/polybar-secondary-mode-banner.log 2>&1 &
fi
if is_active eDP-1; then
    polybar primary-mode-banner > /tmp/polybar-primary-mode-banner.log 2>&1 &
fi

sleep 0.4
for w in $(xdotool search --class Polybar 2>/dev/null); do
    name=$(xdotool getwindowname "$w" 2>/dev/null)
    case "$name" in
        *mode-banner*) xdotool windowraise "$w" 2>/dev/null ;;
    esac
done
disown -a 2>/dev/null || true
