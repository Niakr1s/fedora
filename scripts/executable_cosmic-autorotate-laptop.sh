#!/bin/bash

DISPLAY_NAME="eDP-1"
WIDTH="1920"
HEIGHT="1080"

# Wait until COSMIC creates the Wayland socket
while [ -z "$WAYLAND_DISPLAY" ]; do
    for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
        if [ -S "$socket" ]; then
            export WAYLAND_DISPLAY=$(basename "$socket")
            break
        fi
    done
    [ -z "$WAYLAND_DISPLAY" ] && sleep 1
done

monitor-sensor --accel | while IFS= read -r line; do
    case "$line" in
        *"Accelerometer orientation changed: normal"*)
            cosmic-randr mode --transform normal "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
            ;;
        *"Accelerometer orientation changed: bottom-up"*)
            cosmic-randr mode --transform rotate180 "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
            ;;
        # *"Accelerometer orientation changed: left-up"*)
        #     cosmic-randr mode --transform rotate90 "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
        #     ;;
        # *"Accelerometer orientation changed: right-up"*)
        #     cosmic-randr mode --transform rotate270 "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
        #     ;;
    esac
done
