#!/usr/bin/env bash

SCRIPT_DIR="$HOME/.local/src/dotfiles/scripts"

"$SCRIPT_DIR/setup_main_start.sh"

rm -rf ~/.config/mineapps.list

"$SCRIPT_DIR/run_stow/main.sh"

stow --adopt --restow \
  autostart \
  clipse \
  docker \
  gemini \
  gtk \
  i3 \
  icons \
  inputrc \
  k9s \
  lazydocker \
  lazysql \
  lnav \
  mineapp-list \
  nwg-look \
  ovpn \
  pavucontrol \
  picom \
  pipewire \
  posting \
  rofi \
  rustdesk \
  scooter \
  ssh \
  sshm \
  termscp \
  termshark \
  thunar \
  user-dirs \
  warpd \
  wavemon \
  wget \
  xarchiver \
  xfce-4 \
  xinit \
  xorg \
  xsettingsd \
  ya-disk \
  -t ~

echo ">>> Installing base packages..."

"$SCRIPT_DIR/install_with_pacman/main.sh"

sudo pacman -S --noconfirm --needed \
  atac \
  binsider \
  bridge-utils \
  brightnessctl \
  cpufetch \
  ctop \
  ddcutil \
  dive \
  dnsmasq \
  docker \
  docker-compose \
  duf \
  dysk \
  flawz \
  gemini-cli \
  gitea \
  github-cli \
  glim \
  gparted \
  gpg-tui \
  gping \
  gsimplecal \
  gufw \
  inotify-tools \
  iptables-nft \
  jq \
  jwt-ui \
  k9s \
  kmon \
  lazydocker \
  libqalculate \
  libsecret \
  lnav \
  lshw \
  mirro-rs \
  netscanner \
  openapi-tui \
  openbsd-netcat \
  oryx \
  picom \
  playerctl \
  pyalpm \
  python-pipx \
  rainfrog \
  rofi-calc \
  rofi-emoji \
  serie \
  soft-serve \
  systemctl-tui \
  systeroid \
  television \
  termscp \
  termshark \
  tor \
  torsocks \
  tracexec \
  trippy \
  vde2 \
  wavemon \
  xorg-xprop

sudo pacman -S --needed rustup

echo ">>> Installing AUR packages (via yay)..."

"$SCRIPT_DIR/install_from_aur/main.sh"

yay -S --noconfirm --needed \
  abook \
  amazing-qr \
  bluetuith-bin \
  brows \
  clipse \
  dblab \
  envx \
  fzf-make \
  gobang-bin \
  jqp-bin \
  lazyjournal \
  lazysql \
  lazyssh-bin \
  mmtui-bin \
  obfs4proxy \
  posting \
  rmtrash \
  rofi-bluetooth-git \
  rofi-greenclip \
  rustdesk-bin \
  rustnet \
  s-tui-git \
  scooter \
  sshm-bin \
  systemd-manager-tui \
  sysz \
  warpd \
  wifitui-bin \
  woeusb \
  xautolock \
  xkblayout-state-git

echo ">>> Installing global npm packages..."
"$SCRIPT_DIR/install_from_npm/main.sh"

echo ">>> Installing ggh..."
curl -fsSL https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh

echo ">>> Applying Xresources..."
cp ~/evangelion.Xresources ~/.Xresources || true
xrdb -merge ~/.Xresources || true

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth

sudo systemctl enable docker
sudo systemctl start docker
sudo gpasswd -a egoreast docker

sudo systemctl enable gitea
sudo systemctl start gitea

"$SCRIPT_DIR/setup_main_in_end.sh"

echo ">>> Configuring bandwhich..."
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)

echo ">>> All done!"
