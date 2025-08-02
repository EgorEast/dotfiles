```
      ██            ██     ████ ██  ██
     ░██           ░██    ░██░ ░░  ░██
     ░██  ██████  ██████ ██████ ██ ░██  █████   ██████
  ██████ ██░░░░██░░░██░ ░░░██░ ░██ ░██ ██░░░██ ██░░░░
 ██░░░██░██   ░██  ░██    ░██  ░██ ░██░███████░░█████
░██  ░██░██   ░██  ░██    ░██  ░██ ░██░██░░░░  ░░░░░██
░░██████░░██████   ░░██   ░██  ░██ ███░░██████ ██████
 ░░░░░░  ░░░░░░     ░░    ░░   ░░ ░░░  ░░░░░░ ░░░░░░

  ▓▓▓▓▓▓▓▓▓▓
 ░▓ about  ▓ custom linux config files
 ░▓ author ▓ egoreast <i@egoreast.ru>
 ░▓▓▓▓▓▓▓▓▓▓
 ░░░░░░░░░░

```

Based on: <https://github.com/xero/dotfiles>

## table of contents

- [managing](#managing)
- [installing](#installing)
- [how it works](#how-it-works)
- [my dotfiles setup](#my-dotfiles-setup)
- [tl;dr](#tldr)
- [install packages](#install-packages)
- [install and setup aider](#install-and-setup-aider)
- [setup kitty](#setupkitty)
- [apply xresources](#apply-xresources)
- [enable necessary services](#enable-necessary-services)
- [setup env variables](#setup-env-variables)

# managing

i manage mine with [gnu stow](http://www.gnu.org/software/stow/), a free, portable, lightweight symlink farm manager. this allows me to keep a versioned directory of all my config files that are virtually linked into place via a single command. this makes sharing these files among many users (root) and computers super simple. and does not clutter your home directory with version control files.

# installing

stow is available for all linux and most other unix like distributions via your package manager.

- `apt install stow`
- `brew install stow`
- `dnf install stow`
- `pacman -S stow`
- `yum install stow`

or clone it [from source](https://savannah.gnu.org/git/?group=stow) and [build it](http://git.savannah.gnu.org/cgit/stow.git/tree/INSTALL) yourself.

# how it works

by default the stow command will create symlinks for files in the parent directory of where you execute the command. since i keep my dots in: `~/.local/src/dotfiles` and all stow commands should be executed in that directory and suffixed with `-t ~` to target the home directory. otherwise they will end up in `~/.local/`.

to install configs execute the stow command with the folder name as the first argument, then target your home directory (or wherever you like).

to install my **fish** configs use the command:

`stow fish -t ~`
this will symlink files like `config.fish` to `~/.config/fish`

**note:** stow can only create a symlink if a config file does not already exist. if a default file was created upon program installation you must delete it first before you can install a new one with stow. this does not apply to directories, only files.

# my dotfiles setup

to fully "install" and setup this repo run the [setup script](https://github.com/xero/dotfiles/blob/main/setup) or something like this:

```sh
# clone and stow
git clone git@github.com:EgorEast/dotfiles.git ~/.local/src/dotfiles &&
 cd ~/.local/src/dotfiles &&
 stow anydesk autostart bash bottom calcurse cmus curl delta dunst fastfetch fish flameshot gemini git glow greenclip gtk-3.0 gtk-4.0 gtk-2.0 htop i3 icons inputrc kitty lazygit mineapp-list mpv nano nekoray neovim nwg-look obs onlyoffice pavucontrol picom pipewire rofi rudesktop spectacle ssh thunar user-dirs vim wget xfce-4 xinit xorg xsettingsd ya-disk ya-music yazi yt-dlp ytsurf xarchiver galculator lazydocker -t ~

# nvim
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa
```

# tl;dr

navigate to your home directory

`cd ~`

clone the repo:

`git clone git@github.com:EgorEast/dotfiles.git`

enter the dotfiles directory

`cd dotfiles`

install the fish settings

`stow fish`

install fish settings for the root user

`sudo stow fish -t /root`

uninstall fish

`stow -D fish`

etc, etc, etc...

# install packages

```sh
sudo pacman -S vim nodejs-lts-jod npm kitty ttf-jetbrains-mono-nerd fish fisher nvim lazygit git-delta trash-cli zoxide ouch glow onefetch ripgrep xclip xsel bottom htop cmus lsd playerctl jq gparted qbittorrent spectacle obs-studio networkmanager-openvpn yt-dlp shortcut redshift blueberry xfce4-clipman-plugin gsimplecal calcurse telegram-desktop libsecret gnome-keyring seahorse ddcutil firefox brightnessctl flameshot galculator tree fastfetch kshutdown picom obsidian vulkan-radeon vulkan-tools vulkan-icd-loader


yay -S yazi-git fish-done yandex-browser onlyoffice-bin portproton ventoy-bin pantum-driver yandex-disk visual-studio-code-bin xkblayout-state-git rofi-greenclip rudesktop anydesk-bin xautolock nekoray-bin whatsapp-linux-desktop ytsurf neohtop lazydocker dysk

sudo npm install -g npm-check-updates @bramus/caniuse-cli @google/gemini-cli

curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz
chmod +x gdu_linux_amd64
mv gdu_linux_amd64 /usr/bin/gdu

```

# install and setup aider

```sh
curl -LsSf https://aider.chat/install.sh | sh

sudo usermod -aG i2c $USER  # добавляем пользователя в группу i2c
sudo modprobe i2c-dev
```

# setup kitty

```sh
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator
```

# apply xresources

```sh
cp ~/evangelion.Xresources ~/.Xresources
xrdb -merge ~/.Xresources
```

# enable necessary services

```sh
sudo systemctl start bluetooth
sudo systemctl enable bluetooth

yandex-disk token
yandex-disk start
```

# setup env variables

```sh
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment; echo -e "\nПроверка:\n$(cat /etc/environment)"'
```
