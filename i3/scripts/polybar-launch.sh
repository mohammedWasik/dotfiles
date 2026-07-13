#!/bin/bash
# Relaunch polybar. Each pill (left / center / right) is its own bar instance
# so we get real Cairo-rendered rounded corners via bar-level `radius`.
#
# The center pill (workspaces) is dynamically resized based on how many
# workspaces currently exist, via polybar `-o` overrides.

# Kill any previous watchers via their lockfiles
WATCH_LOCK=/tmp/polybar-ws-watch.pid
FS_LOCK=/tmp/polybar-fs-watch.pid
for L in "$WATCH_LOCK" "$FS_LOCK"; do
    if [ -f "$L" ]; then
        kill "$(cat "$L")" 2>/dev/null
        rm -f "$L"
    fi
done
pkill -f polybar-ws-watch 2>/dev/null
pkill -f polybar-fs-watch 2>/dev/null

pkill -x polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.2; done
rm -f /tmp/polybar-hidden

is_active() {
    xrandr | grep "^$1 connected" | grep -qE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+'
}

# --- dynamic center-pill sizing -------------------------------------------
# Sum per-workspace widths: 1-digit ≈ 44px, 2-digit ≈ 58px, + 20px padding,
# + 200px headroom for short i3-mode banners (resize etc.).
calc_ws_width() {
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

# Screen assumed 1920 wide; center pill horizontally within that.
calc_center_offset_x() {
    local w=$1
    echo $(( (1920 - w) / 2 ))
}

launch_center_bar() {
    local bar_name=$1
    local w
    w=$(calc_ws_width)
    local x
    x=$(calc_center_offset_x "$w")
    POLYBAR_CENTER_WIDTH=$w POLYBAR_CENTER_OFFSET_X=$x \
        polybar "$bar_name" > "/tmp/polybar-${bar_name}.log" 2>&1 &
}

# --- launch static side bars + dynamic center + mode banner ---------------
if is_active DP-2; then
    polybar secondary-left        > /tmp/polybar-secondary-left.log        2>&1 &
    polybar secondary-right       > /tmp/polybar-secondary-right.log       2>&1 &
    polybar secondary-mode-banner > /tmp/polybar-secondary-mode-banner.log 2>&1 &
    launch_center_bar secondary-center
    sleep 0.3
fi

if is_active eDP-1; then
    polybar primary-left        > /tmp/polybar-primary-left.log        2>&1 &
    polybar primary-right       > /tmp/polybar-primary-right.log       2>&1 &
    polybar primary-mode-banner > /tmp/polybar-primary-mode-banner.log 2>&1 &
    launch_center_bar primary-center
fi

sleep 1

# Raise polybar windows so they stay on top of newly-focused apps.
for w in $(xdotool search --class Polybar 2>/dev/null); do
    xdotool windowraise "$w" 2>/dev/null
done

# --- workspace-count + mode watcher (relaunches only the center bars) ----
(
    exec -a polybar-ws-watch bash -c '
        # Only workspace-count changes retrigger a full relaunch.
        # Mode changes are handled by polybar itself (label-mode) since
        # restarting polybar mid-mode drops the mode indicator.
        prev=$(i3-msg -t get_workspaces 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
        i3-msg -t subscribe -m "[ \"workspace\" ]" 2>/dev/null | while read -r _; do
            cur=$(i3-msg -t get_workspaces 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "$prev")
            if [ "$cur" != "$prev" ]; then
                prev=$cur
                pkill -f "polybar (primary|secondary)-center$" 2>/dev/null
                sleep 0.2
                ~/.config/i3/scripts/polybar-center-launch.sh
            fi
        done
    '
) &
echo $! > "$WATCH_LOCK"

# --- fullscreen watcher (hides pills when any window is fullscreen) -------
(
    exec -a polybar-fs-watch bash ~/.config/i3/scripts/polybar-fs-watch.sh
) &
echo $! > "$FS_LOCK"

# --- mode watcher (spawns/kills the bottom mode-banner bar) ---------------
MODE_LOCK=/tmp/polybar-mode-watch.pid
if [ -f "$MODE_LOCK" ]; then
    kill "$(cat "$MODE_LOCK")" 2>/dev/null
    rm -f "$MODE_LOCK"
fi
pkill -f polybar-mode-watch 2>/dev/null
(
    exec -a polybar-mode-watch bash -c '
        get_mode() {
            i3-msg -t get_binding_state 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get(\"name\",\"default\"))" 2>/dev/null || echo default
        }
        map_banners() {
            for w in $(xdotool search --name mode-banner 2>/dev/null); do
                xdotool windowmap "$w" 2>/dev/null
                xdotool windowraise "$w" 2>/dev/null
            done
        }
        unmap_banners() {
            for w in $(xdotool search --name mode-banner 2>/dev/null); do
                xdotool windowunmap "$w" 2>/dev/null
            done
        }
        # Wait for banner windows to exist then start hidden.
        sleep 1
        unmap_banners
        prev="default"
        i3-msg -t subscribe -m "[ \"mode\" ]" 2>/dev/null | while read -r _; do
            cur=$(get_mode)
            if [ "$cur" != "$prev" ]; then
                if [ "$cur" = "default" ]; then unmap_banners; else map_banners; fi
                prev=$cur
            fi
        done
    '
) &
echo $! > "$MODE_LOCK"

disown -a 2>/dev/null || true
