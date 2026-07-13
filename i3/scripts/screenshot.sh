#!/bin/bash
# Wrapper script for flameshot GUI (v14+: daemon must be running, do NOT kill it)

[[ -z "$DISPLAY" ]] && export DISPLAY=:0
export QT_QPA_PLATFORM=xcb

# Ensure daemon is running (no-op if already running)
if ! pgrep -x flameshot > /dev/null; then
    flameshot &
    sleep 0.5
fi

flameshot gui
