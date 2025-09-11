#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

rm -rf ~/.config/mineapps.list

stow --adopt --restow \
  anydesk \
  atac \
  autostart \
  bash \
  bat \
  bluetuith \
  calcurse \
  cmus \
  curl \
  delta \
  docker \
  dunst \
  fastfetch \
  feh \
  fish \
  flameshot \
  galculator \
  gemini \
  git \
  glow \
  gobang \
  greenclip \
  gtk \
  i3 \
  icons \
  inputrc \
  kitty \
  lazydocker \
  lazygit \
  lsd \
  mailcap \
  mineapp-list \
  mpv \
  nano \
  ncdu \
  nekoray \
  neovim \
  nwg-look \
  obs \
  onlyoffice \
  ovpn \
  pavucontrol \
  picom \
  pipewire \
  qalculate \
  redshift \
  rofi \
  rudesktop \
  sc-im \
  spectacle \
  ssh \
  tg \
  thunar \
  user-dirs \
  vim \
  wget \
  winapps \
  xarchiver \
  xfce-4 \
  xinit \
  xorg \
  xsettingsd \
  ya-disk \
  ya-music \
  yazi \
  yt-dlp \
  ytsurf \
  -t ~

echo ">>> Installing base packages..."
sudo pacman -S --noconfirm --needed \
  atac \
  bandwhich \
  bat \
  blueberry \
  brightnessctl \
  calcurse \
  cloc \
  cmus \
  curl \
  ddcutil \
  dialog \
  docker \
  docker-compose \
  fastfetch \
  fd \
  feh \
  firefox \
  fish \
  fisher \
  flameshot \
  freerdp \
  galculator \
  git \
  git-delta \
  glow \
  gnome-keyring \
  gparted \
  gping \
  gsimplecal \
  hledger \
  hledger-ui \
  iproute2 \
  jq \
  kitty \
  lazygit \
  libnotify \
  libqalculate \
  libsecret \
  lsd \
  ncdu \
  networkmanager-openvpn \
  nodejs-lts-jod \
  npm \
  nvim \
  obs-studio \
  obsidian \
  onefetch \
  openbsd-netcat \
  oryx \
  ouch \
  picom \
  playerctl \
  python-pipx \
  qbittorrent \
  redshift \
  ripgrep \
  rustup \
  seahorse \
  shotcut \
  spectacle \
  tabiew \
  telegram-desktop \
  tor \
  torsocks \
  trash-cli \
  tree \
  trippy \
  ttf-jetbrains-mono-nerd \
  urlview \
  vim \
  vulkan-icd-loader \
  vulkan-radeon \
  vulkan-tools \
  wine \
  xclip \
  xsel \
  yt-dlp \
  zoxide

echo ">>> Installing AUR packages (via yay)..."
yay -S --noconfirm --needed \
  anydesk-bin \
  bitchat-tui \
  blobdrop-git \
  bluetuith-bin \
  downloader-cli \
  dysk \
  fish-done \
  gobang-bin \
  hellwal \
  lazydocker \
  mmtui-bin \
  nekoray-bin \
  obfs4proxy \
  onlyoffice-bin \
  pandoc-bin \
  pantum-driver \
  portproton \
  puffin \
  rofi-bluetooth-git \
  rofi-games \
  rofi-greenclip \
  rudesktop \
  sc-im \
  speedread-git \
  sysz \
  telegram-tg \
  torbrowser-launcher \
  ttf-ms-fonts \
  ventoy-bin \
  visual-studio-code-bin \
  whatsapp-linux-desktop \
  xautolock \
  xkblayout-state-git \
  yandex-browser \
  yandex-disk \
  yandex-music \
  yazi-git \
  ytsurf

echo ">>> Installing neovim..."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa

echo ">>> Installing global npm packages..."
sudo npm i -g \
  @bramus/caniuse-cli \
  @builder.io/ai-shell \
  @google/gemini-cli \
  live-server \
  npm-check-updates \
  pnq

echo ">>> Setting up pipx..."
pipx ensurepath
sudo pipx ensurepath --global || true
pipx install git+https://github.com/rmaake1/terminal-rain-lightning.git

echo ">>> Installing ggh..."
curl -fsSL https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh

echo ">>> Installing Aider..."
curl -LsSf https://aider.chat/install.sh | sh

echo ">>> Setting up kitty as default terminal..."
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator

echo ">>> Applying Xresources..."
cp ~/evangelion.Xresources ~/.Xresources || true
xrdb -merge ~/.Xresources || true

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth
yandex-disk token || true
yandex-disk start || true

echo ">>> Configuring bandwhich..."
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)

echo ">>> Updating environment variables..."
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment'

echo ">>> All done!"
