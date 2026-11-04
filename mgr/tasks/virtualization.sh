#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

function virtualization_manual() {
  glow <<EOF

# Short virt-manager manual

## Enabling User Session

It’s very simple, in the main VMM window, click on File -> Add Connection... and in the Hypervisor: dropdown menu, select QEMU/KVM user session.
From now on run VMs in user mode.

## Enabling 3D acceleration

- Display Splice
Type: Spice server, everything else disabled

- Add Hardware
Choose Graphics and set 'type="egl-headless"' instead of 'type="spice"' in XML tab

- 'Video *' (it's above 'watchdow' in the left menu)
Tick on 3D Acceleration

- Enjoy!

EOF
}

function virtualization_install() {
  log_info "installing virtualization group"
  pkg_install "@virtualization"

  log_info "enabling libvirtd"
  sudo systemctl enable --now libvirtd

  virtualization_manual
}

case "$1" in
manual | help | h | -h | --help)
  virtualization_manual
  ;;
*)
  virtualization_install
  ;;
esac
