#!/bin/bash

DISPLAY_NAME="eDP-1"
WIDTH="1920"
HEIGHT="1080"

monitor-sensor --accel | while IFS= read -r line; do
    case "$line" in
        *"Accelerometer orientation changed: normal"*)
            cosmic-randr mode --transform normal "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
            ;;
        *"Accelerometer orientation changed: left-up"*)
            cosmic-randr mode --transform rotate90 "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
            ;;
        *"Accelerometer orientation changed: bottom-up"*)
            cosmic-randr mode --transform rotate180 "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
            ;;
        *"Accelerometer orientation changed: right-up"*)
            cosmic-randr mode --transform rotate270 "$DISPLAY_NAME" "$WIDTH" "$HEIGHT"
            ;;
    esac
done
