#!/usr/bin/env bash

echo ">>> Updating system..."
pkg upgrade

pkg install stow

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

stow --adopt --restow \
  bash \
  bat \
  btop \
  curl \
  delta \
  fastfetch \
  fish \
  git \
  glow \
  jqp \
  lazygit \
  mpv \
  nano \
  ncdu \
  nvim \
  termux \
  yazi \
  yt-dlp \
  -t ~

echo ">>> Installing base packages..."

pkg install \
  atuin \
  bat \
  curl \
  fastfetch \
  fd \
  fish \
  fx \
  git \
  git-delta \
  glow \
  htop \
  lazygit \
  lsd \
  ncdu \
  neovim \
  nodejs \
  onefetch \
  ripgrep \
  root-repo \
  termux-api \
  tree \
  tsu \
  x11-repo \
  yazi \
  zoxide

echo ">>> Installing MiUnlock..."
curl -sS https://raw.githubusercontent.com/offici5l/MiUnlockTool/main/.install | bash

echo ">>> Installing global npm packages..."
npm i -g @bramus/caniuse-cli

echo ">>> Installing packages with pip..."
pip install trash-cli

echo ">>> Set fish as shell..."
ln -sf /data/data/com.termux/files/usr/bin/fish ~/.termux/shell

echo ">>> Setup Storage..."
termux-setup-storage

echo ">>> All done!"
