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
  tree \
  x11-repo \
  yazi \
  zoxide

echo ">>> Installing global npm packages..."
sudo npm i -g @bramus/caniuse-cli

echo ">>> All done!"
