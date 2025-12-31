#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

sudo pacman -S stow

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

. ./run_stow/main.sh

echo ">>> Installing base packages..."

. ./install_with_pacman/main.sh

echo ">>> Installing AUR packages (via yay)..."

. ./install_from_aur/main.sh

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
