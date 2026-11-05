#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

PKGS=(
  snapper libdnf5-plugin-actions btrfs-assistant inotify-tools git make
)

pkg_install "${PKGS[@]}"

log_info "snapper: configuring"
sudo snapper -c root create-config /
sudo snapper -c root set-config ALLOW_USERS="$USER" SYNC_ACL=yes
sudo restorecon -RFv /.snapshots

log_info "snapper: updating /etc/updatedb.conf to tell updatedb to skip any directory named .snapshots when indexing the filesystem"
if grep -qE '^[[:space:]]*PRUNENAMES[[:space:]]*=.*\.snapshots' /etc/updatedb.conf; then
    echo "PRUNENAMES already includes .snapshots — nothing to do."
elif grep -qE '^[[:space:]]*PRUNENAMES[[:space:]]*=' /etc/updatedb.conf; then
    echo "PRUNENAMES exists but lacks .snapshots — adding it to the existing line..."
    sudo sed -i -E 's/^([[:space:]]*PRUNENAMES[[:space:]]*=.*)$/\1 ".snapshots"/' /etc/updatedb.conf && \
        echo "Done. Updated line: $(grep -E '^[[:space:]]*PRUNENAMES[[:space:]]*=' /etc/updatedb.conf)"
else
    echo "No PRUNENAMES line found — appending a new one..."
    echo 'PRUNENAMES = ".snapshots"' | sudo tee -a /etc/updatedb.conf > /dev/null && \
        echo "Done. Appended: PRUNENAMES = \".snapshots\""
fi

log_info "snapper: setting config"
sudo snapper -c root set-config \
  TIMELINE_CREATE=yes \
  TIMELINE_CLEANUP=yes \
  TIMELINE_MIN_AGE=1800 \
  TIMELINE_LIMIT_HOURLY=10 \
  TIMELINE_LIMIT_DAILY=3 \
  TIMELINE_LIMIT_WEEKLY=1 \
  TIMELINE_LIMIT_MONTHLY=1 \
  TIMELINE_LIMIT_QUARTERLY=0 \
  TIMELINE_LIMIT_YEARLY=0 \
  NUMBER_CLEANUP=yes \
  NUMBER_MIN_AGE=3600 \
  NUMBER_LIMIT=8 \
  NUMBER_LIMIT_IMPORTANT=4

log_info "snapper: creating current snapshot"
sudo snapper -c root create --description "mgr/task/snapper.sh run"

log_info "snapper: enabling dnf snapshots"
sudo mkdir -p /etc/dnf/libdnf5-plugins/actions.d
sudo tee /etc/dnf/libdnf5-plugins/actions.d/snapper.actions > /dev/null <<'EOF'
# Get the snapshot description (the dnf command)
pre_transaction::::/usr/bin/sh -c echo\ "tmp.cmd=$(ps\ -o\ command\ --no-headers\ -p\ '${pid}')"

# Creates pre snapshot before the transaction and stores the snapshot number
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_pre_number=$(snapper\ create\ -t\ pre\ -c\ number\ -p\ -d\ '${tmp.cmd}')"

# Creates post snapshot after the transaction if the pre snapshot number exists
post_transaction::::/usr/bin/sh -c [\ -n\ "${tmp.snapper_pre_number}"\ ]\ &&\ snapper\ create\ -t\ post\ --pre-number\ "${tmp.snapper_pre_number}"\ -c\ number\ -d\ "${tmp.cmd}"\ ;\ echo\ tmp.snapper_pre_number\ ;\ echo\ tmp.cmd
EOF


log_info "snapper: enabling snapper services"
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
