#!/usr/bin/env bash

until WAYLAND_DISPLAY=$(systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p') && [ -n "$WAYLAND_DISPLAY" ]; do
  sleep 0.5
done
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"

# Automatically find the touchscreen device node
TOUCH_DEVICE=$(libinput list-devices | awk '
  /^Device:/ { dev=$0 }
  /^Kernel:/ { kern=$2 }
  /Capabilities:.*touch/ { print kern; exit }
')

# Fallback if auto-detection fails (replace with your actual /dev/input/eventX)
TOUCH_DEVICE=${TOUCH_DEVICE:-/dev/input/event0}

echo "TOUCH_DEVICE=$TOUCH_DEVICE"

# Kill any existing lisgd instances
pkill -x lisgd

TOGGLE_WS='pkill -x cosmic-workspaces || cosmic-workspaces &'
TOGGLE_APP='pkill -x cosmic-app-library || cosmic-app-library &'

lisgd -d "$TOUCH_DEVICE" \
  -g "1,UD,T,*,R,sh -c '$TOGGLE_WS'" \
  -g "1,DU,B,*,R,sh -c '$TOGGLE_WS'" \
  -g "1,RL,R,*,R,sh -c '$TOGGLE_APP'" \
  -g "1,LR,L,*,R,sh -c '$TOGGLE_APP'"
