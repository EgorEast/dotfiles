#!/usr/bin/env bash

. ./setup_main_start.sh

. ./run_stow/main.sh

echo ">>> Installing base packages..."

. ./install_with_pacman/main.sh

echo ">>> Installing AUR packages (via yay)..."

. ./install_from_aur/main.sh

echo ">>> Installing global npm packages..."
. ./install_from_npm/main.sh

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth

. ./setup_main_in_end.sh

echo ">>> All done!"
