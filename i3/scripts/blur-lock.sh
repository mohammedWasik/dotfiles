#!/bin/bash

W=1920
H=1080

PX=$(echo "scale=0; $W * 22 / 100" | bc)
TIME_Y=$(echo "scale=0; $H * 40 / 100" | bc)
DATE_Y=$(echo "scale=0; $H * 50 / 100" | bc)
IND_Y=$(echo "scale=0;  $H * 65 / 100" | bc)

TIME_SIZE=$(echo "scale=0; $W / 45" | bc)
DATE_SIZE=$(echo "scale=0; $W / 85" | bc)

i3lock \
    --blur=5 \
    --nofork \
    --clock \
    --indicator \
    \
    --time-str="%I:%M %p" \
    --time-font="FiraCode Nerd Font" \
    --time-size="$TIME_SIZE" \
    --time-color=ffffffff \
    --time-pos="$PX:$TIME_Y" \
    \
    --date-str="%A, %d %B" \
    --date-font="FiraCode Nerd Font" \
    --date-size="$DATE_SIZE" \
    --date-color=ebdbb2ff \
    --date-pos="$PX:$DATE_Y" \
    \
    --ind-pos="$PX:$IND_Y" \
    --radius=35 \
    --inside-color=1e1e2099 \
    --insidewrong-color=1e1e2099 \
    --insidever-color=1e1e2099 \
    --ring-color=a8998466 \
    --ringver-color=b8bb26ff \
    --ringwrong-color=fb4934ff \
    --keyhl-color=b8bb26ff \
    --bshl-color=fe8019ff \
    --separator-color=00000000 \
    --verif-text="" \
    --wrong-text=""
