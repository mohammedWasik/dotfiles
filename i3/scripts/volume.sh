#!/bin/bash
# Unified audio control: volume up/down, mute-toggle, microphone toggle
# Usage: volume.sh up|down|mute-toggle|mic-toggle

if [ -z "$1" ]; then
    echo "Usage: $0 up|down|mute-toggle|mic-toggle"
    exit 1
fi

case "$1" in
    up)
        CURRENT_PERCENT=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -1 | tr -d '%')
        NEW_PERCENT=$((CURRENT_PERCENT + 5))
        if [ "$NEW_PERCENT" -gt 100 ]; then
            NEW_PERCENT=100
        fi
        pactl set-sink-volume @DEFAULT_SINK@ "${NEW_PERCENT}%"
        sleep 0.1
        ACTUAL_PERCENT=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -1 | tr -d '%')
        notify-send -t 1000 -r 1001 -h "int:value:$ACTUAL_PERCENT" "🔊 Volume: ${ACTUAL_PERCENT}%"
        ;;
    down)
        CURRENT_PERCENT=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -1 | tr -d '%')
        NEW_PERCENT=$((CURRENT_PERCENT - 5))
        if [ "$NEW_PERCENT" -lt 0 ]; then
            NEW_PERCENT=0
        fi
        pactl set-sink-volume @DEFAULT_SINK@ "${NEW_PERCENT}%"
        sleep 0.1
        ACTUAL_PERCENT=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -1 | tr -d '%')
        notify-send -t 1000 -r 1001 -h "int:value:$ACTUAL_PERCENT" "🔉 Volume: ${ACTUAL_PERCENT}%"
        ;;
    mute-toggle)
        MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        if [ "$MUTE" = "yes" ]; then
            notify-send -t 1000 -r 1002 "🔊 Unmuted"
        else
            notify-send -t 1000 -r 1002 "🔇 Muted"
        fi
        ;;
    mic-toggle)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        MUTE=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
        if [ "$MUTE" = "yes" ]; then
            notify-send -t 1000 -r 1003 "🎤 Mic: OFF"
        else
            notify-send -t 1000 -r 1003 "🎤 Mic: ON"
        fi
        ;;
    *)
        echo "Usage: $0 up|down|mute-toggle|mic-toggle"
        exit 1
        ;;
esac
