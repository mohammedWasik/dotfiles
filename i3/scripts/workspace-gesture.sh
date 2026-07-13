#!/bin/bash
# Unified workspace navigation for touch gestures
# Usage: workspace-gesture.sh next|prev

if [ -z "$1" ]; then
    echo "Usage: $0 next|prev"
    exit 1
fi

case "$1" in
    next)
        DISPLAY=:0 /usr/bin/i3-msg workspace next
        ;;
    prev)
        DISPLAY=:0 /usr/bin/i3-msg workspace prev
        ;;
    *)
        echo "Usage: $0 next|prev"
        exit 1
        ;;
esac
