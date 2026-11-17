#!/usr/bin/env bash

# Automatically find the touchscreen device node
TOUCH_DEVICE=$(libinput list-devices | awk '
  /^Device:/ { dev=$0 }
  /^Kernel:/ { kern=$2 }
  /Capabilities:.*touch/ { print kern; exit }
')

# Fallback if auto-detection fails (replace with your actual /dev/input/eventX)
TOUCH_DEVICE=${TOUCH_DEVICE:-/dev/input/event0}

# Kill any existing lisgd instances
pkill -x lisgd

# Start lisgd:
lisgd -d "$TOUCH_DEVICE" \
  -g "1,UD,T,*,R,cosmic-workspaces" \
  -g "1,DU,B,*,R,cosmic-workspaces" \
  -g "1,RL,R,*,R,cosmic-app-library" \
  -g "1,LR,L,*,R,cosmic-app-library" \
