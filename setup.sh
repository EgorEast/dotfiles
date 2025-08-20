#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Creating symlinks with stow..."
cd ~/.local/src/dotfiles

stow --adopt --restow \
  anydesk autostart bash calcurse cmus curl delta dunst fastfetch fish flameshot \
  gemini git glow greenclip gtk i3 icons inputrc kitty lazygit mineapp-list mpv \
  nano nekoray neovim nwg-look obs onlyoffice pavucontrol picom pipewire rofi \
  rudesktop spectacle ssh thunar user-dirs vim wget xfce-4 xinit xorg xsettingsd \
  ya-disk ya-music yazi yt-dlp ytsurf xarchiver galculator lazydocker redshift \
  ncdu bluetuith lsd qalculate bat tg mailcap feh sc-im ovpn gobang -t ~

echo ">>> Installing neovim..."
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa

echo ">>> Installing base packages..."
sudo pacman -S --noconfirm \
  vim nodejs-lts-jod npm kitty ttf-jetbrains-mono-nerd \
  fish fisher nvim lazygit git-delta trash-cli zoxide ouch glow onefetch \
  ripgrep xclip xsel cmus lsd playerctl jq gparted qbittorrent spectacle \
  obs-studio networkmanager-openvpn yt-dlp shotcut redshift blueberry \
  gsimplecal calcurse telegram-desktop libsecret gnome-keyring seahorse \
  ddcutil firefox brightnessctl flameshot galculator tree fastfetch picom \
  obsidian vulkan-radeon vulkan-tools vulkan-icd-loader cloc bat tabiew \
  tor torsocks ncdu fd rustup wine python-pipx libqalculate bandwhich urlview \
  feh docker docker-compose gping hledger hledger-ui oryx trippy

echo ">>> Installing AUR packages (via yay)..."
yay -S --noconfirm \
  yazi-git fish-done yandex-browser onlyoffice-bin portproton ventoy-bin \
  pantum-driver yandex-disk visual-studio-code-bin xkblayout-state-git \
  rofi-greenclip rudesktop anydesk-bin xautolock nekoray-bin \
  whatsapp-linux-desktop ytsurf lazydocker dysk rofi-games blobdrop-git \
  bitchat-tui downloader-cli hellwal speedread-git torbrowser-launcher \
  obfs4proxy yandex-music rofi-bluetooth-git bluetuith-bin mmtui-bin \
  telegram-tg sc-im pandoc-bin gobang-bin puffin sysz

echo ">>> Installing global npm packages..."
sudo npm i -g npm-check-updates @bramus/caniuse-cli @google/gemini-cli pnq

echo ">>> Setting up pipx..."
pipx ensurepath
sudo pipx ensurepath --global || true
pipx install git+https://github.com/rmaake1/terminal-rain-lightning.git

echo ">>> Installing ggh..."
curl -fsSL https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh

echo ">>> Setting up kitty as default terminal..."
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator

echo ">>> Applying Xresources..."
cp ~/evangelion.Xresources ~/.Xresources || true
xrdb -merge ~/.Xresources || true

echo ">>> Enabling necessary services..."
sudo systemctl enable --now reflector.timer
sudo systemctl enable --now bluetooth
yandex-disk token || true
yandex-disk start || true

echo ">>> Configuring bandwhich..."
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)

echo ">>> Updating environment variables..."
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment'

echo ">>> All done!"
