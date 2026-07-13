#!/bin/bash
# Relaunch only the center (workspace) polybar pills, sizing them based on
# workspace count AND current i3 mode (so mode banners like "resize" or
# "(e)xternal-only ..." fit without being clipped).

get_mode() {
    i3-msg -t get_binding_state 2>/dev/null \
        | python3 -c "import json,sys; print(json.load(sys.stdin).get('name','default'))" \
        2>/dev/null || echo default
}

calc_width() {
    # Center pill sized to workspace count only; mode indicator lives in
    # the dedicated bottom mode-banner bar, not here.
    i3-msg -t get_workspaces 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print(200); sys.exit()
total = 20
for w in d:
    n = w.get('num', 1)
    total += 58 if n >= 10 else 44
print(max(80, total))
" || echo 200
}

is_active() {
    xrandr | grep "^$1 connected" | grep -qE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+'
}

export I3_MODE
I3_MODE=$(get_mode)
w=$(calc_width)
x=$(( (1920 - w) / 2 ))

export POLYBAR_CENTER_WIDTH=$w
export POLYBAR_CENTER_OFFSET_X=$x

if is_active DP-2; then
    polybar secondary-center > /tmp/polybar-secondary-center.log 2>&1 &
fi
if is_active eDP-1; then
    polybar primary-center > /tmp/polybar-primary-center.log 2>&1 &
fi

sleep 0.5
for w in $(xdotool search --class Polybar 2>/dev/null); do
    xdotool windowraise "$w" 2>/dev/null
done
disown -a 2>/dev/null || true
