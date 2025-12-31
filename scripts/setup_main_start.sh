#!/usr/bin/env bash

set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

sudo pacman -S stow

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles
