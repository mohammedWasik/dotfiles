#!/bin/bash
# Low battery notification script
# Sends notification every 2 minutes when battery < 10% unless charger is connected
# Optimized: checks less frequently when battery is healthy

# Exit if already running
LOCKFILE="/tmp/low-battery-notify.lock"
if [ -f "$LOCKFILE" ] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
    exit 0
fi
echo $$ > "$LOCKFILE"
trap "rm -f $LOCKFILE; exit" INT TERM EXIT

BATTERY_DEVICE=$(upower -e | grep 'BAT' | head -1)
LOW_THRESHOLD=10
CHECK_INTERVAL_LOW=120    # 2 minutes when battery is low
CHECK_INTERVAL_NORMAL=600 # 10 minutes when battery is healthy (less CPU usage)

while true; do
    # Get battery percentage and state
    if [ -n "$BATTERY_DEVICE" ]; then
        PERCENTAGE=$(upower -i "$BATTERY_DEVICE" | grep 'percentage' | awk '{print $2}' | sed 's/%//')
        STATE=$(upower -i "$BATTERY_DEVICE" | grep 'state' | awk '{print $2}')
        
        # Check if battery is low and discharging
        if [ -n "$PERCENTAGE" ] && [ "$PERCENTAGE" -lt "$LOW_THRESHOLD" ] && [ "$STATE" = "discharging" ]; then
            notify-send -u critical -i battery-caution "Low Battery Warning" "Battery is at ${PERCENTAGE}%. Please connect your charger."
            sleep "$CHECK_INTERVAL_LOW"  # Check every 2 min when low
        elif [ -n "$PERCENTAGE" ] && [ "$PERCENTAGE" -lt "$LOW_THRESHOLD" ]; then
            # Battery is low but charging - still check frequently in case charger is disconnected
            sleep "$CHECK_INTERVAL_LOW"
        else
            sleep "$CHECK_INTERVAL_NORMAL"  # Check every 10 min when healthy
        fi
    else
        sleep "$CHECK_INTERVAL_NORMAL"  # Default to normal interval if no battery found
    fi
done

