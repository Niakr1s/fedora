#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

params=(
  "selinux=0" # hate selinux
  "clearcpuid=514" # for gaming
  "split_lock_detect=off" # for gaming
  "usbcore.quirks=057e:2009:ik" # fixes my gamepad
  "usb-storage.quirks=0bc2:ab80:u" # fixes my 20TB drive
)

log_info "Applying kernel params: ${params[*]}"
sudo grubby --update-kernel=ALL --args="${params[*]}"
