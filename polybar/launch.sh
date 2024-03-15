#!/bin/bash

# Terminate already running Polybar instances
killall -q polybar

# Wait until processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar on the primary monitor ($sm)
echo "--- Starting Polybar on primary monitor ($sm) ---"
MONITOR=$sm polybar --config=~/.config/polybar/config.ini primary &

# Launch Polybar on the secondary monitor ($mm)
echo "--- Starting Polybar on secondary monitor ($mm) ---"
MONITOR=$mm polybar --config=~/.config/polybar/config.ini secondary &

echo "Polybar launched..."

