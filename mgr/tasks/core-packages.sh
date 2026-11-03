#!/usr/bin/env bash

# Core package set shared by both machines (desktop & laptop).
# Desktop-only heavy stuff lives in the other tasks (see profiles/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

COPRS=(
  oak443/clash-verge-rev
  lizardbyte/stable
)

PKGS=(
  snapper libdnf5-plugin-actions
  glow
  nvtop
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
  rofi
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
  cairo
  tdf
  caddy mkcert
  scanmem       # cheat engine alternative
  weechat

  # services
  Sunshine
  kdeconnectd

  # libs
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
  clash-verge-rev
  btrfs-assistant
  kitty
  strawberry
  firewall-config
  keepassxc
  krita
  librecad
  xreader
  qbittorrent
  sqlitebrowser
  remmina
  HandBrake-gui
  kid3
  mpv
  telegram-desktop
  obs-studio
  cosmic-viewer
  zeal

  # games
  luanti # minecraft like
)

PKGS_REMOVE=(
  okular
  cosmic-player
  rhythmbox
  thunderbird
  nheko
)

AM_PKGS=(
  lossless-cut
  crossmacro
)

FLATPAKS=(
  "com.github.tchx84.Flatseal"

  "com.valvesoftware.Steam|--filesystem=xdg-config/MangoHud:ro"
  "net.lutris.Lutris|--filesystem=xdg-config/MangoHud:ro" # it works better via flatpak, lol
)

AUR_PKGS=(
  lisgd iio-niri
)

GO_PKGS=(
  github.com/jorgerojas26/lazysql@latest
)

function post_install() {
  # enable syncthing
  systemctl --user enable --now syncthing.service

  # create root config for snapper
  sudo snapper -c root create-config / || true

  # install python versions
  uv python install 3.13
  uv python install 3.14
}

copr_install "${COPRS[@]}"
pkg_install "${PKGS[@]}"
pkg_remove "${PKGS_REMOVE[@]}"
flatpak_install "${FLATPAKS[@]}"
go_install "${GO_PKGS[@]}"
cargo_install "${CARGO_PKGS[@]}"
am_install "${AM_PKGS[@]}"

post_install
