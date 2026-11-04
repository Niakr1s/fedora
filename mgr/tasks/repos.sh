#!/usr/bin/env bash

set -o pipefail

echo "Disabling openh264..."
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=0

echo "Enabling Terra repos..."
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

echo "Enabling RPM Fusion repo..."
sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

echo "If launched the first time - you should run `sudo dnf update && sudo dnf upgrade` and reboot NOW"
