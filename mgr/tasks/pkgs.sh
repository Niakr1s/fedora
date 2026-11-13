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

PKG_URLS=(
  "https://github.com/mops1k/plasma-keyboard-custom/releases/download/v6.7.90-custom-r47/kcm-plasma-keyboard-custom-6.7.90-1.fc44.x86_64.rpm|kcm-plasma-keyboard-custom"
  "https://github.com/mops1k/plasma-keyboard-custom/releases/download/v6.7.90-custom-r47/plasma-keyboard-custom-6.7.90-1.fc44.x86_64.rpm|plasma-keyboard-custom"
)

PKGS=(
  @multimedia

  copr-cli
  glow
  borgbackup
  yazi
  bottom
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
  fuse-sshfs
  kiwix-desktop kiwix-tools

  # services
  Sunshine

  # drivers
  intel-media-driver

  # codecs
  libavcodec-freeworld
  libva-utils

  # libs
  qt qt6-qtbase-devel qt6-qtbase-private-devel qt6-qtdeclarative-devel qt6-qtmultimedia-devel qt6-qtvirtualkeyboard-devel qt6-qtwayland-devel
  kf6-kcoreaddons-devel kf6-ki18n-devel kf6-kcmutils-devel kf6-kconfig-devel kf6-kcrash-devel kf6-kglobalaccel-devel
  libplasma-devel layer-shell-qt-devel
  wayland-protocols-devel
  cairo
  gtk4-layer-shell
  libevdev libevdev-devel
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
  cmake extra-cmake-modules
  ninja make
  bear # for generating compile_commands.json: bear -- mak
  uv
  golang
  rust
  luajit luarocks
  nodejs npm deno
  cargo lldb
  ruby ruby-devel tk

  # Fonts
  cascadia-mono-nf-fonts
  google-carlito-fonts # Calibri replacement
  gdouros-symbola-fonts # symbola fonts

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
  vlc
  telegram-desktop
  obs-studio
  clash-verge-rev
  easyeffects

  # games
  luanti # minecraft like

  # games tools
  steam lutris
  mangohud gamemode gamemode.i686
  gameconqueror
)

PKGS_REMOVE=(
  elisa-player
  dragon
  zeal
  zig # will be managed by asdf

  libva-intel-driver
  libva-intel-media-driver
)

AM_PKGS=(
  lossless-cut
  crossmacro
  ventoy
)

ASDF_PLUGINS=(
  zig zls
)

FLATPAKS=(
  # "flathub|com.github.tchx84.Flatseal"

  # "flathub|com.valvesoftware.Steam|--filesystem=xdg-config/MangoHud:ro"
  # "flathub|net.lutris.Lutris|--filesystem=xdg-config/MangoHud:ro" # it works better via flatpak, lol

  # "cosmic|com.github.codevardhan.caffeine-applet"
  # "cosmic|dev.DBrox.CosmicSystemMonitor"
  # "cosmic|io.github.marcelogomes90.cosmic-ext-applet-status-hub"
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

  # enable overcommit memory for virtual machines
  echo "vm.overcommit_memory = 1" | sudo tee /etc/sysctl.d/99-vm-overcommit_memory.conf
  sudo sysctl --system &>/dev/null

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
pkg_url_install "${PKG_URLS[@]}"

pkg_remove "${PKGS_REMOVE[@]}"
flatpak_install "${FLATPAKS[@]}"
go_install "${GO_PKGS[@]}"
cargo_install "${CARGO_PKGS[@]}"
am_install "${AM_PKGS[@]}"
asdf_install "${ASDF_PLUGINS[@]}"

post_install
