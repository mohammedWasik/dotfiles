#!/bin/bash
# Watch for any fullscreen state (i3-level OR X11 _NET_WM_STATE_FULLSCREEN
# from browsers/video players) and hide/show polybar pills accordingly.

any_window_fullscreen() {
    # Check i3 fullscreen_mode on any window
    local i3_fs
    i3_fs=$(i3-msg -t get_tree 2>/dev/null | python3 -c "
import json, sys
try:
    tree = json.load(sys.stdin)
except Exception:
    print(0); sys.exit()
def has_fs(n):
    # Only actual X11 windows can be user-fullscreen; the __i3_scratch
    # workspace has fullscreen_mode=1 as a permanent internal state.
    if n.get('window') and n.get('fullscreen_mode', 0) > 0:
        return True
    for c in n.get('nodes', []) + n.get('floating_nodes', []):
        if has_fs(c):
            return True
    return False
print(1 if has_fs(tree) else 0)
" 2>/dev/null || echo 0)

    if [ "$i3_fs" = "1" ]; then
        echo 1
        return
    fi

    # Check any X11 window with _NET_WM_STATE_FULLSCREEN
    if xprop -root _NET_CLIENT_LIST 2>/dev/null | grep -oE '0x[0-9a-fA-F]+' | while read -r w; do
        if xprop -id "$w" _NET_WM_STATE 2>/dev/null | grep -q "_NET_WM_STATE_FULLSCREEN"; then
            echo hit
            break
        fi
    done | grep -q hit; then
        echo 1
    else
        echo 0
    fi
}

hide_polybars() {
    for w in $(xdotool search --class Polybar 2>/dev/null); do
        xdotool windowunmap "$w" 2>/dev/null
    done
}

# Show only the top pills (left/center/right). Skip the mode-banner —
# whether it should be visible is decided by the mode-watcher based on
# the current i3 mode, not by fullscreen state.
show_polybars() {
    # Don't restore if the user has manually hidden polybars
    [ -f /tmp/polybar-hidden ] && return
    for w in $(xdotool search --class Polybar 2>/dev/null); do
        name=$(xdotool getwindowname "$w" 2>/dev/null)
        case "$name" in
            *mode-banner*) continue ;;
        esac
        xdotool windowmap "$w" 2>/dev/null
        xdotool windowraise "$w" 2>/dev/null
    done
}

# Initial reconcile
if [ "$(any_window_fullscreen)" = "1" ]; then
    hide_polybars; prev=1
else
    show_polybars; prev=0
fi

# Listen for both i3 window events AND poll periodically for X11-level fs.
{
    i3-msg -t subscribe -m '[ "window" ]' 2>/dev/null | while read -r _; do echo tick; done &
    while sleep 1; do echo tick; done
} | while read -r _; do
    cur=$(any_window_fullscreen)
    if [ "$cur" != "$prev" ]; then
        if [ "$cur" = "1" ]; then hide_polybars; else show_polybars; fi
        prev=$cur
    fi
done
