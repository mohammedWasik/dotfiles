#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Create separate config for primary monitor (laptop)
cat > /tmp/polybar-primary.ini << EOF
[bar/primary]
monitor = eDP-1
width = 1920
height = 35
offset-x = 0
offset-y = 1080
wm-restack = i3
override-redirect = false
monitor-strict = false
radius = 0
background = #bb1d2021
foreground = #fbf1c7
line-size = 3
line-color = #fabd2f
border-size = 2
border-color = #00000000
padding-left = 2
padding-right = 2
module-margin-left = 1
module-margin-right = 2
font-0 = FiraCode Nerd Font:size=11;1
font-1 = FiraCode Nerd Font:size=11;0
font-2 = FiraCode Nerd Font:size=11;1
modules-left = i3
modules-center = popup-calendar
modules-right = cpu memory battery timezone bd-time sg-time au-time
tray-position = right
tray-padding = 2
cursor-click = pointer
cursor-scroll = ns-resize

[module/i3]
type = internal/i3
pin-workspaces = true
show-urgent = true
strip-wsnumbers = true
index-sort = true
enable-click = true

[module/popup-calendar]
type = custom/script
exec = date +"%Y-%m-%d %H:%M"
interval = 1
format-prefix = "󰃭 "
format-prefix-foreground = #fabd2f
click-left = exec --no-startup-id "cal"
click-right = exec --no-startup-id "zenity --calendar --title='Calendar' --date-format='%Y-%m-%d'"

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "󰻠 "
format-prefix-foreground = #fabd2f
label = %percentage:2%%

[module/memory]
type = internal/memory
interval = 2
format-prefix = "󰍛 "
format-prefix-foreground = #fabd2f
label = %used%

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 98
format-charging = <animation-charging> <label-charging>
label-charging = %percentage%%
format-discharging = <ramp-capacity> <label-discharging>
label-discharging = %percentage%%
format-full-prefix = "󰁹 "
format-full-prefix-foreground = #fabd2f
ramp-capacity-0 = 󰁺
ramp-capacity-1 = 󰁻
ramp-capacity-foreground = #fabd2f
animation-charging-0 = 󰂄
animation-charging-foreground = #fabd2f
animation-charging-framerate = 750

[module/timezone]
type = custom/script
exec = echo "+06"
interval = 60
format-prefix = "󰀗 "
format-prefix-foreground = #fabd2f

[module/bd-time]
type = custom/script
exec = TZ=Asia/Dhaka date +"%I:%M %p"
interval = 1
format-prefix = "BD "
format-prefix-foreground = #fabd2f

[module/sg-time]
type = custom/script
exec = TZ=Asia/Singapore date +"%I:%M %p"
interval = 1
format-prefix = "SG "
format-prefix-foreground = #fabd2f

[module/au-time]
type = custom/script
exec = TZ=Australia/Sydney date +"%I:%M %p"
interval = 1
format-prefix = "AU "
format-prefix-foreground = #fabd2f
EOF

# Create separate config for secondary monitor (HDMI)
cat > /tmp/polybar-secondary.ini << EOF
[bar/secondary]
monitor = HDMI-2
width = 1920
height = 35
offset-x = 0
offset-y = 0
wm-restack = i3
override-redirect = false
monitor-strict = false
radius = 0
background = #bb1d2021
foreground = #fbf1c7
line-size = 3
line-color = #fabd2f
border-size = 2
border-color = #00000000
padding-left = 2
padding-right = 2
module-margin-left = 1
module-margin-right = 2
font-0 = FiraCode Nerd Font:size=11;1
font-1 = FiraCode Nerd Font:size=11;0
font-2 = FiraCode Nerd Font:size=11;1
modules-left = i3 title
modules-center = popup-calendar
modules-right = cpu memory timezone bd-time sg-time au-time
tray-position = right
tray-padding = 2
cursor-click = pointer
cursor-scroll = ns-resize

[module/i3]
type = internal/i3
pin-workspaces = true
show-urgent = true
strip-wsnumbers = true
index-sort = true
enable-click = true

[module/title]
type = internal/xwindow
label = %title:0:60:...%

[module/popup-calendar]
type = custom/script
exec = date +"%Y-%m-%d %H:%M"
interval = 1
format-prefix = "󰃭 "
format-prefix-foreground = #fabd2f
click-left = exec --no-startup-id "cal"
click-right = exec --no-startup-id "zenity --calendar --title='Calendar' --date-format='%Y-%m-%d'"

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "󰻠 "
format-prefix-foreground = #fabd2f
label = %percentage:2%%

[module/memory]
type = internal/memory
interval = 2
format-prefix = "󰍛 "
format-prefix-foreground = #fabd2f
label = %used%

[module/timezone]
type = custom/script
exec = echo "+06"
interval = 60
format-prefix = "󰀗 "
format-prefix-foreground = #fabd2f

[module/bd-time]
type = custom/script
exec = TZ=Asia/Dhaka date +"%I:%M %p"
interval = 1
format-prefix = "BD "
format-prefix-foreground = #fabd2f

[module/sg-time]
type = custom/script
exec = TZ=Asia/Singapore date +"%I:%M %p"
interval = 1
format-prefix = "SG "
format-prefix-foreground = #fabd2f

[module/au-time]
type = custom/script
exec = TZ=Australia/Sydney date +"%I:%M %p"
interval = 1
format-prefix = "AU "
format-prefix-foreground = #fabd2f
EOF

# Launch polybar for primary monitor (laptop) with separate config
echo "---" | tee -a /tmp/polybar-primary.log
polybar -c /tmp/polybar-primary.ini primary 2>&1 | tee -a /tmp/polybar-primary.log & disown

# Longer delay to ensure proper separation
sleep 1

# Launch polybar for secondary monitor (HDMI) ONLY if connected
if xrandr | grep -q "HDMI-2 connected"; then
    echo "---" | tee -a /tmp/polybar-secondary.log
    polybar -c /tmp/polybar-secondary.ini secondary 2>&1 | tee -a /tmp/polybar-secondary.log & disown
    echo "Secondary Polybar launched..."
else
    echo "HDMI-2 not connected, skipping secondary bar"
fi

echo "Primary Polybar launched..."
