#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

FILENAME="90-sysrq.conf"
FILEPATH="/etc/sysctl.d/$FILENAME"

log_info "Creating $FILEPATH"
sudo tee "$FILEPATH" << EOF
kernel.sysrq = 1
EOF

log_info "Enabling reisub"
sudo sysctl -p "$FILEPATH"

log_info "Now, when your system freezes, hold Alt + SysRq (the Print Screen key on most keyboards) and type the following sequence, one key at a time, with a short pause between each: R → E → I → S → U → B\nThe mnemonic to remember the order: Reboot Even If System Utterly Broken. The system will sync disks and reboot cleanly."
