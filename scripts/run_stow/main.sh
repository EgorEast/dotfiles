#!/usr/bin/env bash

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

stow --adopt --restow \
  atuin \
  bash \
  bat \
  btop \
  crow-translate \
  cruise \
  curl \
  delta \
  dunst \
  fastfetch \
  feh \
  fish \
  flameshot \
  gdu \
  git \
  glow \
  greenclip \
  kitty \
  lazygit \
  libreoffice \
  lsd \
  mpv \
  nano \
  ncdu \
  nvim \
  obs \
  onboard \
  onlyoffice \
  spectacle \
  ventoy \
  v2rayN \
  vim \
  yazi \
  yt-dlp \
  -t ~
