#!/usr/bin/env bash

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
  glow \
  jqp \
  lazygit \
  mpv \
  nano \
  ncdu \
  yazi \
  yt-dlp \
  -t ~

echo ">>> Installing base packages..."

pkg install \
  bat \
  htop \
  curl \
  fastfetch \
  fd \
  fish \
  fx \
  git \
  git-delta \
  glow \
  lazygit \
  lsd \
  ncdu \
  nodejs \
  neovim \
  onefetch \
  ripgrep \
  tree \
  yazi \
  zoxide

echo ">>> Installing global npm packages..."
sudo npm i -g @bramus/caniuse-cli

echo ">>> All done!"
