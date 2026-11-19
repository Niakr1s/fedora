#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

CONFIG_FILE="/etc/greetd/cosmic-greeter.toml"
TARGET_USER="user"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: $CONFIG_FILE not found."
    exit 1
fi

if grep -q "^\[initial_session\]" "$CONFIG_FILE"; then
    echo "Autologin is already configured in $CONFIG_FILE."
    exit 0
fi

sudo tee -a "$CONFIG_FILE" > /dev/null <<EOF

[initial_session]
command = "start-cosmic"
user = "$TARGET_USER"
EOF

log_info "Autologin enabled for '$TARGET_USER'. Reboot to apply."
