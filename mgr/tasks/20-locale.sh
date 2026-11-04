#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

MAIN_LOCALE="en_US.UTF-8"
TIME_LOCALE="en_GB.UTF-8"

LOCALE_CONF_PATH="/etc/locale.conf"

log_info "Setting $LOCALE_CONF_PATH ..."

# Directly write to locale.conf, systemd will handle the rest
sudo tee "$LOCALE_CONF_PATH" > /dev/null <<EOF
LANG=$MAIN_LOCALE
LC_TIME=$TIME_LOCALE
EOF

log_info "$LOCALE_CONF_PATH set."

# Optional: Verify if the locale is available
if ! localectl list-locales | grep -q "^$TIME_LOCALE"; then
    log_error "Locale $TIME_LOCALE is not available on this system."
    exit 1
fi

log_info "Locale configuration applied successfully."
