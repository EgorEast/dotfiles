#!/usr/bin/env bash

echo ">>> Installing neovim..."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa

echo ">>> Setting up kitty as default terminal..."
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator

echo ">>> Configuring libvirt..."
. ./scripts/set-libvirt-fw.sh

echo ">>> Configuring onboard..."
. ./onboard/install.sh

echo ">>> Configuring bat..."
bat cache --build

echo ">>> Updating environment variables..."
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=chromium/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment'

echo ">>> Configuring git..."
git config filter.koreader-ignore-sync-server.clean "./koreader/.config/koreader/git-filter-script.sh"
# Настройте smudge фильтр (просто пропускает данные)
git config filter.koreader-ignore-sync-server.smudge "cat"
