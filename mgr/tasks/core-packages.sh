#!/usr/bin/env bash

# Core package set shared by both machines (desktop & laptop).
# Desktop-only heavy stuff lives in the other tasks (see profiles/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

COPRS=(
  oak443/clash-verge-rev
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
  swappy

  # doc stuff
  ghostscript poppler poppler-data
  djvulibre libgxps libspectre texlive

  # prog
  rust cargo golang

  # Fonts
  cascadia-mono-nf-fonts

  # GUI
  clash-verge-rev
  btrfs-assistant
  kitty
)

FLATPAKS=(
  com.valvesoftware.Steam
  net.lutris.Lutris
  no.mifi.losslesscut
  io.github.alper_han.crossmacro
)

# TODO: move these pkgs
OLD_PKGS=(
  # archive
  unarchiver zip unzip unrar lz4 7zip

  # libs
  gtk4-layer-shell
  gtk-layer-shell
  libevdev
  # needed for joystickwake
  python-pyudev
  python-evdev
  python-dbus-fast
  python-xlib
  python-huggingface-hub
  python-pywayland
  fuse2

  # lsp
  tree-sitter tree-sitter-cli
  python-lsp-server ty
  bash-language-server
  gopls
  marksman
  python-pipenv
  python-pytest
  shfmt
  shellcheck
  tidy
  zls

  # deps
  ddcutil
  i2c-tools
  wtype
  ydotool

  # fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-nerd-fonts-symbols-mono
  ttf-nerd-fonts-symbols
  ttf-firacode-nerd
  ttf-iosevka-nerd

  # services
  xdg-desktop-portal-gnome
  xdg-desktop-portal-wlr
  syncthing
  caddy mkcert

  # programming
  cmake ninja make
  bear # for generating compile_commands.json: bear -- mak
  uv
  go
  rust
  lua51 luajit luarocks
  nodejs npm deno
  cargo lldb
  ruby tk ruby-stdlib
  zig

  # theming
  qt5ct
  qt6ct
  adw-gtk-theme

  # gui
  imv krita
  libreoffice
  librecad
  mission-center
  qbittorrent
  nautilus
  sqlitebrowser
  xreader
  weechat
  l3afpad
  gnome-disk-utility
  font-manager
  keepassxc
  dconf-editor
  remmina
  kitty
  handbrake
  strawberry
  kdeconnect
  kid3
  strawberry
  mpv
  telegram-desktop
  moonlight-qt
  sunshine
  obs-studio-browser # cachyos's obs-studio
  gpu-screen-recorder
  kdenlive
  squeekboard
  gthumb
  zeal
  opencode
  blanket

  # browsers
  firefox
  chromium

  # hardware
  cpu-x
  hardinfo2 apcupsd fwupd
  occt

  # games stuff
  lutris
  proton-cachyos-slr wine # either one or another will work
  mangohud
  gamescope
  gamemode
  steam
  scanmem       # cheat engine alternative
  gameconqueror # doesn't work though

  # native games
  luanti # minecraft like
  angband
)

AUR_PKGS=(
  lisgd iio-niri
  vkbasalt
  lib32-vkbasalt
)

GO_PKGS=(
  github.com/jorgerojas26/lazysql@latest
)

function post_install() {
  # needed for correct nvidia GPU work
  flatpak override --user --env=VK_LOADER_DRIVERS_SELECT="*"

  # enable syncthing
  systemctl --user enable --now syncthing.service

  # create root config for snapper
  sudo snapper -c root create-config / || true
}

copr_install "${COPRS[@]}"
pkg_install "${PKGS[@]}"
flatpak_install "${FLATPAKS[@]}"
go_install "${GO_PKGS[@]}"
cargo_install "${CARGO_PKGS[@]}"

post_install
