#!/bin/bash
# Toggle polybar visibility. When hidden: gaps top goes to 0 so windows
# use the full screen. When shown: gaps top restores to 44 (bar height).

HIDDEN=/tmp/polybar-hidden

if [ -f "$HIDDEN" ]; then
    rm -f "$HIDDEN"
    for w in $(xdotool search --class Polybar 2>/dev/null); do
        name=$(xdotool getwindowname "$w" 2>/dev/null)
        case "$name" in *mode-banner*) continue ;; esac
        xdotool windowmap "$w" 2>/dev/null
        xdotool windowraise "$w" 2>/dev/null
    done
    i3-msg gaps top all set 44
else
    touch "$HIDDEN"
    for w in $(xdotool search --class Polybar 2>/dev/null); do
        xdotool windowunmap "$w" 2>/dev/null
    done
    i3-msg gaps top all set 0
fi
