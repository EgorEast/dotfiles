#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

sudo pacman -S stow

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

. ./scripts/run_stow.sh

echo ">>> Installing base packages..."

. ./scripts/install_with_pacman.sh

echo ">>> Installing AUR packages (via yay)..."

. ./scripts/install_from_aur.sh

echo ">>> Installing neovim..."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa

echo ">>> Installing global npm packages..."

. ./scripts/install_from_npm.sh

echo ">>> Setting up pipx..."
pipx ensurepath
sudo pipx ensurepath --global || true
pipx install git+https://github.com/rmaake1/terminal-rain-lightning.git

echo ">>> Installing ggh..."
curl -fsSL https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh

echo ">>> Installing Aider..."
curl -LsSf https://aider.chat/install.sh | sh

echo ">>> Setting up kitty as default terminal..."
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator

echo ">>> Applying Xresources..."
cp ~/evangelion.Xresources ~/.Xresources || true
xrdb -merge ~/.Xresources || true

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth
sudo systemctl enable docker
sudo systemctl start docker
sudo gpasswd -a egoreast docker
yandex-disk token || true
yandex-disk start || true

echo ">>> Configuring bandwhich..."
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)

echo ">>> Configuring bat..."
bat cache --build

echo ">>> Updating environment variables..."
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment'

echo ">>> Run and pull ollama"
ollama serve &
ollama pull deepseek-coder-v2 &
ollama pull gpt-oss &
ollama pull qwen3-coder

echo ">>> Configuring git..."
git config filter.koreader-ignore-sync-server.clean "./koreader/.config/koreader/git-filter-script.sh"
# Настройте smudge фильтр (просто пропускает данные)
git config filter.koreader-ignore-sync-server.smudge "cat"

echo ">>> All done!"
