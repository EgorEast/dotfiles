#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

sudo pacman -S stow

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

stow --adopt --restow \
  bash \
  bat \
  btop \
  curl \
  delta \
  dunst \
  fastfetch \
  feh \
  fish \
  flameshot \
  glow \
  greenclip \
  jqp \
  kitty \
  lazygit \
  mpv \
  nano \
  ncdu \
  throne \
  yazi \
  yt-dlp \
  -t ~

echo ">>> Installing base packages..."

sudo pacman -S --noconfirm --needed \
  atuin \
  bat \
  blueberry \
  btop \
  chromium \
  curl \
  fastfetch \
  fd \
  feh \
  firefox \
  fish \
  fisher \
  flameshot \
  fx \
  git \
  git-delta \
  glow \
  kitty \
  lazygit \
  lsd \
  ncdu \
  networkmanager-openvpn \
  nodejs-lts-jod \
  npm \
  nvim \
  obsidian \
  onefetch \
  ouch \
  qbittorrent \
  ripgrep \
  shotcut \
  spectacle \
  telegram-desktop \
  trash-cli \
  tree \
  ttf-jetbrains-mono-nerd \
  vulkan-icd-loader \
  vulkan-radeon \
  vulkan-tools \
  wine \
  xclip \
  xsel \
  yazi \
  zoxide

echo ">>> Installing AUR packages (via yay)..."

yay -S --noconfirm --needed \
  blobdrop-git \
  cruise \
  downloader-cli \
  fish-done \
  linutil \
  onlyoffice-bin \
  pantum-driver \
  portproton \
  throne \
  ttf-ms-fonts \
  ventoy-bin \
  whatsapp-linux-desktop \
  yandex-browser \
  yandex-music

echo ">>> Installing global npm packages..."
sudo npm i -g @bramus/caniuse-cli

echo ">>> Setting up kitty as default terminal..."
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth

echo ">>> Updating environment variables..."
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment'

echo ">>> All done!"
