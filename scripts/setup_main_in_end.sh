#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")"

echo ">>> Installing neovim..."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa

echo ">>> Setting up kitty as default terminal..."
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator

echo ">>> Configuring libvirt..."
sudo bash "$SCRIPT_DIR/set-libvirt-fw.sh"

echo ">>> Configuring onboard..."
. ./onboard/install.sh

echo ">>> Configuring bat..."
bat cache --build

set_env_var() {
  local key="$1"
  local value="$2"
  local file="/etc/environment"

  if grep -q "^${key}=" "$file"; then
    sudo sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    echo "${key}=${value}" | sudo tee -a "$file" >/dev/null
  fi
}

echo ">>> Updating environment variables..."
set_env_var EDITOR nvim
set_env_var VISUAL nvim
set_env_var BROWSER chromium

sudo awk '!seen[$0]++ && NF' /etc/environment | sudo tee /etc/environment >/dev/null

echo ">>> Configuring git..."
git config filter.koreader-ignore-sync-server.clean "./koreader/.config/koreader/git-filter-script.sh"
# Настройте smudge фильтр (просто пропускает данные)
git config filter.koreader-ignore-sync-server.smudge "cat"
