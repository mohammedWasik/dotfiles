#!/bin/bash
# Unified brightness control: up, down
# Usage: brightness.sh up|down

BRIGHTNESSCTL=/usr/bin/brightnessctl
NOTIFYSEND=/usr/bin/notify-send

if [ -z "$1" ]; then
    echo "Usage: $0 up|down"
    exit 1
fi

CUR=$("$BRIGHTNESSCTL" get)
MAX=$("$BRIGHTNESSCTL" max)
CURRENT_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($CUR/$MAX)*100}")

case "$1" in
    up)
        NEW_PERCENT=$(awk "BEGIN {printf \"%.1f\", $CURRENT_PERCENT + 5}")
        if (( $(awk "BEGIN {print ($NEW_PERCENT > 100)}") )); then
            NEW_PERCENT=100
        fi
        BRIGHTNESS_VALUE=$(awk "BEGIN {printf \"%.0f\", ($NEW_PERCENT/100)*$MAX}")
        "$BRIGHTNESSCTL" set "$BRIGHTNESS_VALUE"
        sleep 0.1
        ACTUAL_CUR=$("$BRIGHTNESSCTL" get)
        ACTUAL_PERCENT_NUM=$(awk "BEGIN {printf \"%.0f\", ($ACTUAL_CUR/$MAX)*100}")
        "$NOTIFYSEND" -t 1000 -r 2001 -h "int:value:$ACTUAL_PERCENT_NUM" "☀️ Brightness: ${ACTUAL_PERCENT_NUM}%"
        ;;
    down)
        if (( $(awk "BEGIN {print ($CURRENT_PERCENT > 5)}") )); then
            NEW_PERCENT=$(awk "BEGIN {printf \"%.1f\", $CURRENT_PERCENT - 5}")
            if (( $(awk "BEGIN {print ($NEW_PERCENT < 5)}") )); then
                NEW_PERCENT=5
            fi
            BRIGHTNESS_VALUE=$(awk "BEGIN {printf \"%.0f\", ($NEW_PERCENT/100)*$MAX}")
            "$BRIGHTNESSCTL" set "$BRIGHTNESS_VALUE"
            sleep 0.1
            ACTUAL_CUR=$("$BRIGHTNESSCTL" get)
            ACTUAL_PERCENT_NUM=$(awk "BEGIN {printf \"%.0f\", ($ACTUAL_CUR/$MAX)*100}")
            "$NOTIFYSEND" -t 1000 -r 2001 -h "int:value:$ACTUAL_PERCENT_NUM" "🌙 Brightness: ${ACTUAL_PERCENT_NUM}%"
        else
            CURRENT_INT=${CURRENT_PERCENT%%.*}
            "$NOTIFYSEND" -t 1000 -r 2001 -h "int:value:$CURRENT_INT" "🌙 Brightness: ${CURRENT_INT}% (Minimum reached)"
        fi
        ;;
    *)
        echo "Usage: $0 up|down"
        exit 1
        ;;
esac
