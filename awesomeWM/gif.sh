#!/bin/bash
# Uses xwinwrap to display given animated .gif in dual monitors.
if [ $# -ne 1 ]; then
    echo 1>&2 Usage: $0 image.gif
    exit 1
fi
gif=$1
killall -9 xwinwrap
killall -9 gifview
# Get monitors resolution
SCR1=`xrandr | awk '/primary/ && /connected/ { print $4 }'`
SCR2=`xrandr | awk '!/primary/ && /connected/ { print $3 }'`

xwinwrap -g $SCR1 -ov -ni -s -nf -- gifview -w WID $gif -a &
xwinwrap -g $SCR2 -ov -ni -s -nf -- gifview -w WID $gif -a &