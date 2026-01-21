#!/usr/bin/env bash

set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

sudo pacman -S --noconfirm --needed stow
