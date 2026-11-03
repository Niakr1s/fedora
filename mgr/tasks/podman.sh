#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

# This will install the needed packages (note the "Windows 11" note below):
pkg_install podman podman-docker podman-compose podlet podman-tui

sudo mkdir -p /etc/containers/registries.conf.d
echo 'unqualified-search-registries = ["docker.io"]' | sudo tee /etc/containers/registries.conf.d/10-unqualified-search-registries.conf > /dev/null

loginctl enable-linger "$USER"

log_info "Enabling podman.socket"
systemctl --user enable --now podman.socket

log_info "Podman installed!"
podman run --rm quay.io/podman/hello
