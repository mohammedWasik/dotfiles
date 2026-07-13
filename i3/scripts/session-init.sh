#!/bin/bash
# i3 startup initialization script
# Consolidates polybar, xset, xinput, and other startup tasks

# ============================================================================
# Power Management Settings
# ============================================================================
# Disable screensaver blanking and enable DPMS with 30-minute timeout
xset s off
xset dpms 1800 1800 1800

# ============================================================================
# Touchpad Configuration
# ============================================================================
# Enable tapping (automatically finds touchpad by name)
TOUCHPAD_ID=$(xinput list | grep -iE "touchpad|synaptics" | grep -oP "id=\K[0-9]+")
if [ -n "$TOUCHPAD_ID" ]; then
    xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1 2>/dev/null || true
fi

# ============================================================================
# Gesture Recognition (libinput-gestures)
# ============================================================================
# Start libinput-gestures for touchpad swipe gestures (workspace switching)
pkill -f libinput-gestures 2>/dev/null
sleep 1
LIBINPUT_GESTURES="/home/zer0/libinput-gestures/libinput-gestures"
if [ -x "$LIBINPUT_GESTURES" ]; then
    "$LIBINPUT_GESTURES" > /tmp/libinput-gestures.log 2>&1 &
    echo "libinput-gestures daemon started"
else
    echo "WARNING: libinput-gestures not found at $LIBINPUT_GESTURES"
fi

# ============================================================================
# Polybar Startup
# ============================================================================
# Delegated to polybar-launch.sh which starts only the bars whose monitor
# is currently active. Same script is invoked at the end of every layout
# switcher (~/.screenlayout/*.sh) so the bars follow the layout.
~/.config/i3/scripts/polybar-launch.sh

# ============================================================================
# Picom Compositor Startup
# ============================================================================
# Start picom compositor for efficient rendering and to prevent CPU spikes
# Uses GLX backend with vsync, Chrome excluded from compositing (unredir-if-possible)
# to avoid hangs during video calls
pkill picom 2>/dev/null
sleep 1
picom -b --log-level warn > /tmp/picom.log 2>&1
if pgrep picom > /dev/null 2>&1; then
    echo "Picom compositor started"
else
    echo "WARNING: Picom failed to start (log: /tmp/picom.log)"
fi

echo "i3 startup complete: polybar and picom initialized"
