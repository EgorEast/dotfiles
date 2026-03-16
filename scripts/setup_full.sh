#!/usr/bin/env bash

SCRIPT_DIR="$HOME/.local/src/dotfiles/scripts"

"$SCRIPT_DIR/setup_main_start.sh"

"$SCRIPT_DIR/run_stow/full.sh"

echo ">>> Installing base packages..."

"$SCRIPT_DIR/install_with_pacman/full.sh"

echo ">>> Installing AUR packages (via yay)..."

"$SCRIPT_DIR/install_from_aur/full.sh"

echo ">>> Installing global npm packages..."
"$SCRIPT_DIR/install_from_npm/full.sh"

echo ">>> Setting up pipx..."
pipx ensurepath
sudo pipx ensurepath --global || true

echo ">>> Installing from pipx..."

"$SCRIPT_DIR/install_from_pipx.sh"

echo ">>> Installing ggh..."
curl -fsSL https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh

echo ">>> Installing Aider..."
curl -LsSf https://aider.chat/install.sh | sh

echo ">>> Applying Xresources..."
cp ~/evangelion.Xresources ~/.Xresources || true
xrdb -merge ~/.Xresources || true

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth

sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

sudo systemctl enable docker
sudo systemctl start docker
sudo gpasswd -a egoreast docker

sudo systemctl enable gitea
sudo systemctl start gitea

ocx init --global

"$SCRIPT_DIR/setup_main_in_end.sh"

yandex-disk token || true
yandex-disk start || true

echo ">>> Configuring bandwhich..."
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)

echo ">>> Run and pull ollama"

ollama serve

read -r -p "Do you want install ollama llms? (y/N): " choice

# If no input, default to "n"
choice=${choice:-"n"}

case $choice in
"n" | "N" | "")
  echo "Skipping llms installation."
  ;;
"y")
  echo "Running llms installation..."
  "./install_llms.sh"
  echo "Full setup completed."
  ;;
*)
  echo "Invalid choice. Exiting."
  exit 1
  ;;
esac

echo ">>> All done!"
