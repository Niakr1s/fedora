#!/usr/bin/env bash
# NVIDIA setup (desktop only — the laptop has an Intel GPU):
#   - nvidia-container-toolkit, nvidia-prime packages
#   - nvidia-pstated daemon to manage GPU performance states

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

PKGS=(
  # drivers
  akmod-nvidia xorg-x11-drv-nvidia-cuda             # nvidia drivers

  # codecs
  libva-nvidia-driver libva-nvidia-driver.i686 libva-nvidia-driver.x86_64

  nvidia-pstated # niakr1s/copr
)

pkg_install "${PKGS[@]}"

function cuda_install() {
  log_info "Installing cuda (https://rpmfusion.org/Howto/CUDA)"
  sudo dnf config-manager addrepo "--from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/fedora44/$(uname -m)/cuda-fedora44.repo" || true
  sudo dnf clean all
  sudo dnf config-manager setopt "cuda-fedora44-$(uname -m).exclude=nvidia-driver*,cuda-drivers*,nvidia-modprobe,nvidia-persistenced,nvidia-settings,nvidia-libXNVCtrl*,nvidia-xconfig,nvidia-open,nvidia-imex,nvidia-kmod-common,libnvidia-fbc,kmod-nvidia-*-dkms,nvidia-fs*,nvidia-gds*,xorg-x11-nvidia*"
  sudo dnf -y install cuda-toolkit xorg-x11-drv-nvidia-cuda
}

function container_toolkit_install() {
  copr_install "@ai-ml/nvidia-container-toolkit"
  pkg_install nvidia-container-toolkit nvidia-container-toolkit-selinux
  sudo nvidia-ctk cdi generate -output /etc/cdi/nvidia.yaml
  podman run --device nvidia.com/gpu=all --rm fedora:latest nvidia-smi
}

cuda_install
container_toolkit_install

flatpak update

log_warn "After the RPM transaction ends, please remember to wait until the kmod has been built. This can take up to 5 minutes on some systems."
