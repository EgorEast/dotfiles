#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/setup_main_start.sh"

. "$SCRIPT_DIR/run_stow/main.sh"

echo ">>> Installing base packages..."

. "$SCRIPT_DIR/install_with_pacman/main.sh"

echo ">>> Installing AUR packages (via yay)..."

. "$SCRIPT_DIR/install_from_aur/main.sh"

echo ">>> Installing global npm packages..."
. "$SCRIPT_DIR/install_from_npm/main.sh"

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth

. "$SCRIPT_DIR/setup_main_in_end.sh"

echo ">>> All done!"
