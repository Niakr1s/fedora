#!/usr/bin/env bash

# Core package set shared by both machines (desktop & laptop).
# Desktop-only heavy stuff lives in the other tasks (see profiles/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

set -o pipefail


COPRS=(
  oak443/clash-verge-rev
  lizardbyte/stable
  niakr1s/copr
  niakr1s/llama-cpp-cmpfix
)

PKGS=(
  copr-cli
  glow
  borgbackup
  yazi
  tealdeer
  btop
  chezmoi
  syncthing
  neovim
  git
  fastfetch
  bubblewrap
  opencode
  eza
  tree bat fd fzf
  mediainfo
  tmux
  zoxide
  duf
  gdu
  direnv
  playerctl
  aria2
  xclip
  ripgrep
  compsize
  ImageMagick
  yt-dlp
  pandoc
  calc
  trash-cli
  pax-utils # lddtree
  lazygit
  hyperfine
  xdg-terminal-exec
  tdf
  caddy mkcert
  scanmem # cheat engine alternative
  weechat
  joystickwake # niakr1s/copr
  python3-tmuxp
  wlopm
  nvtop
  renameutils
  llama-cpp-cmpfix
  fuse-sshfs

  # services
  Sunshine

  # libs
  cairo
  gtk4-layer-shell
  libevdev
  python-pyudev
  python-evdev
  python-dbus-fast
  python-xlib
  python-huggingface-hub
  python-pywayland

  # archive
  unar zip unzip unrar lz4 7zip

  # doc stuff
  ghostscript poppler poppler-data
  djvulibre libgxps libspectre texlive

  # prog
  patchelf
  gcc gcc-c++
  cmake ninja make
  bear # for generating compile_commands.json: bear -- mak
  uv
  golang
  rust
  luajit luarocks
  nodejs npm deno
  cargo lldb
  ruby ruby-devel tk
  zig

  # Fonts
  cascadia-mono-nf-fonts

  # GUI
  kitty
  strawberry
  keepassxc
  qbittorrent
  sqlitebrowser
  remmina
  HandBrake-gui
  kid3
  mpv
  telegram-desktop
  obs-studio
  zeal

  # games
  luanti # minecraft like
)

PKGS_REMOVE=(
  elisa-player
  dragon
)

AM_PKGS=(
  lossless-cut
  crossmacro
  ventoy
)

FLATPAKS=(
  "flathub|com.github.tchx84.Flatseal"

  "flathub|com.valvesoftware.Steam|--filesystem=xdg-config/MangoHud:ro"
  "flathub|net.lutris.Lutris|--filesystem=xdg-config/MangoHud:ro" # it works better via flatpak, lol

  # "cosmic|com.github.codevardhan.caffeine-applet"
  # "cosmic|dev.DBrox.CosmicSystemMonitor"
  # "cosmic|io.github.marcelogomes90.cosmic-ext-applet-status-hub"
)

AUR_PKGS=(
  lisgd iio-niri
)

GO_PKGS=(
  github.com/jorgerojas26/lazysql@latest
)

CARGO_PKGS=(
  chezmoi_modify_manager
)

function post_install() {
  # enable lingering
  loginctl enable-linger "$USER"

  # enable syncthing
  systemctl --user enable --now syncthing.service

  # enable sshd
  sudo systemctl enable --now sshd.service

  # install python versions
  uv python install 3.13
  uv python install 3.14

  # fix alt+shift switch keyboard layouts in a file
  # /etc/X11/xorg.conf.d/00-keyboard.conf
  sudo localectl set-x11-keymap us pc105 "" ""

  # update flatpak afterwards
  flatpak update -y
}

copr_install "${COPRS[@]}"

sudo dnf install -y ffmpeg --allowerasing # we install ffmpeg separatedly
pkg_install "${PKGS[@]}"

pkg_remove "${PKGS_REMOVE[@]}"
flatpak_install "${FLATPAKS[@]}"
go_install "${GO_PKGS[@]}"
cargo_install "${CARGO_PKGS[@]}"
am_install "${AM_PKGS[@]}"

post_install

log_info "Install amneziavpn client manually from 'https://github.com/amnezia-vpn/amnezia-client/releases/download/5.1.0.6/AmneziaVPN_5.1.0.6_linux_x64.run'"
