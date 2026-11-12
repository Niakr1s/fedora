#!/bin/bash
# .helpers.sh – shared utilities for mgr scripts

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Install one or more APT packages
copr_install() {
  local coprs=("$@")
  for copr in "${coprs[@]}"; do
    log_info "Enabling copr: $copr"
    sudo sudo dnf copr enable -y "$copr"
  done
}

# Install one or more APT packages
pkg_install() {
  local pkgs=("$@")
  log_info "Installing: ${pkgs[*]}"
  sudo sudo dnf install -y "${pkgs[@]}"
}

# Download and install rpms
pkg_url_install() {
  local tmpdir
  tmpdir=$(mktemp -d)
  cd "$tmpdir" || return 1

  for spec in "$@"; do
    local url="${spec%|*}"      # part before the pipe
    local pkgname="${spec##*|}" # part after the pipe
    if ! rpm -q "$pkgname" >/dev/null 2>&1; then
      wget -O "$pkgname.rpm" "$url" &&
        echo "Downloaded: $url" || echo "Failed: $spec" >&2
    else
      echo "Already installed, skipping: $pkgname"
    fi
  done

  sudo dnf install -y ./*.rpm

  rm ./*.rpm
}

# Install one or more APT packages
pkg_remove() {
  local pkgs=("$@")
  log_info "Removing: ${pkgs[*]}"
  sudo sudo dnf remove -y "${pkgs[@]}"
}

flatpak_install() {
  # flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/
  flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak override --user --env=VK_LOADER_DRIVERS_SELECT="*" # needed for correct nvidia GPU work

  local pkgs=("$@")
  log_info "Installing: ${pkgs[*]}"

  for entry in "${pkgs[@]}"; do
    IFS='|' read -r repo id overrides <<< "$entry"
    flatpak install -y "$repo" "$id"
    # shellcheck disable=SC2086
    [[ -n "$overrides" ]] && flatpak override --user $overrides "$id"
  done
}

# Install a AM package
am_install() {
    command_exists am || {
        curl -sSf https://raw.githubusercontent.com/ivan-hc/AM/main/AM-INSTALLER | sh -s -- -i am
    }

    local pkgs=("$@")
    for pkg in "${pkgs[@]}"; do
        if command_exists "$pkg"; then
            log_info "Skipping AM package (exists): $pkg"
        else
            log_info "Installing AM package: $pkg"
            am -i "$pkg"
        fi
    done
}


# Install a Go package via go install
#
# Each entry is "<pkg>". To add flags for a specific package, append
# "| <args>" after it (e.g. "@latest|--tags a,b,c"); those args apply only
# to that one package's `go install`.
go_install() {
  command_exists go || {
    pkg_install go
  }

  local pkgs=("$@")
  local entry pkg extra=()
  for entry in "${pkgs[@]}"; do
    if [[ "$entry" == *"|"* ]]; then
      pkg="${entry%%|*}"
      read -ra extra <<<"${entry#*|}"
    else
      pkg="$entry"
    fi

    if ((${#extra[@]})); then
      log_info "Installing Go package: $pkg (flags: ${extra[*]})"
      go install "${extra[@]}" "$pkg"
    else
      log_info "Installing Go package: $pkg"
      go install "$pkg"
    fi
  done
}

# Install a Cargo package
cargo_install() {
  command_exists cargo || {
    pkg_install cargo
  }

  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    log_info "Installing Cargo package: $pkg"
    cargo install "$pkg"
  done
}

add_sudoers_systemctl() {
  local service="${1:?Usage: add_sudoers_systemctl <service-name>}"
  local sudoers_file="/etc/sudoers.d/${service//[@.]/_}"
  local cmds=(start stop restart status is-active)
  local rule="${USER} ALL=(ALL) NOPASSWD:"
  local first=1
  for c in "${cmds[@]}"; do
    if [ $first -eq 1 ]; then first=0; else rule+=","; fi
    rule+=" /bin/systemctl ${c} ${service}"
  done

  echo "$rule" | sudo visudo -c -f - >/dev/null || {
    echo "invalid rule" >&2
    return 1
  }
  echo "$rule" | sudo install -m 0440 -o root -g root /dev/stdin "$sudoers_file"
}
