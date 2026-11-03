#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log_info "Preparing to install comfyui..."
log_info "Select all defaults except for pytorch version, choose 'modern'"
curl -fsSL https://get.umeai.art/comfyui.sh | sh
