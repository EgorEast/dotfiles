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
- [about packages](#about-packages)

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
 stow anydesk autostart bash bottom calcurse cmus curl delta dunst fastfetch fish flameshot gemini git glow greenclip gtk htop i3 icons inputrc kitty lazygit mineapp-list mpv nano nekoray neovim nwg-look obs onlyoffice pavucontrol picom pipewire rofi rudesktop spectacle ssh thunar user-dirs vim wget xfce-4 xinit xorg xsettingsd ya-disk ya-music yazi yt-dlp ytsurf xarchiver galculator lazydocker redshift ncdu bluetuith lsd -t ~

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
sudo pacman -S vim nodejs-lts-jod npm kitty ttf-jetbrains-mono-nerd fish fisher nvim lazygit git-delta trash-cli zoxide ouch glow onefetch ripgrep xclip xsel bottom htop cmus lsd playerctl jq gparted qbittorrent spectacle obs-studio networkmanager-openvpn yt-dlp shotcut redshift blueberry gsimplecal calcurse telegram-desktop libsecret gnome-keyring seahorse ddcutil firefox brightnessctl flameshot galculator tree fastfetch picom obsidian vulkan-radeon vulkan-tools vulkan-icd-loader cloc bat tabiew tor torsocks ncdu fd rustup tdf-git wine python-pipx


yay -S yazi-git fish-done yandex-browser onlyoffice-bin portproton ventoy-bin pantum-driver yandex-disk visual-studio-code-bin xkblayout-state-git rofi-greenclip rudesktop anydesk-bin xautolock nekoray-bin whatsapp-linux-desktop ytsurf neohtop lazydocker dysk rofi-games portmaster-bin blobdrop-git bitchat-tui downloader-cli hellwal speedread-git torbrowser-launcher obfs4proxy yandex-music rofi-bluetooth-git bluetuith-bin mmtui-bin

sudo npm i -g npm-check-updates @bramus/caniuse-cli @google/gemini-cli pnq

pipx ensurepath
sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
pipx install git+https://github.com/rmaake1/terminal-rain-lightning.git

curl https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh
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
sudo systemctl enable --now reflector.timer

sudo systemctl start bluetooth
sudo systemctl enable bluetooth

yandex-disk token
yandex-disk start
```

# setup env variables

```sh
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment; echo -e "\nПроверка:\n$(cat /etc/environment)"'
```

# about packages

## Installed via pacman

- **bat** – `cat` replacement with syntax highlighting. ([docs](https://github.com/sharkdp/bat))
- **blueberry** – GUI Bluetooth manager. ([docs](https://github.com/linuxmint/blueberry))
- **bottom** – TUI system monitor with graphs. ([docs](https://github.com/ClementTsang/bottom))
- **brightnessctl** – CLI brightness control. ([docs](https://github.com/Hummer12007/brightnessctl))
- **calcurse** – TUI calendar and task manager. ([docs](https://github.com/lfos/calcurse))
- **cloc** – Count lines of code. ([docs](https://github.com/AlDanial/cloc))
- **cmus** – Lightweight console music player. ([docs](https://cmus.github.io/))
- **ddcutil** – Monitor settings control via DDC/CI. ([docs](https://www.ddcutil.com/))
- **fastfetch** – Fast system info fetcher. ([docs](https://github.com/fastfetch-cli/fastfetch))
- **fd** – Fast alternative to `find`. ([docs](https://github.com/sharkdp/fd))
- **firefox** – Web browser. ([docs](https://support.mozilla.org/))
- **fish** – User-friendly shell with autosuggestions and syntax highlighting. ([docs](https://fishshell.com/docs/current/))
- **fisher** – Plugin manager for Fish shell. ([docs](https://github.com/jorgebucaran/fisher))
- **flameshot** – Screenshot tool with annotation. ([docs](https://flameshot.org/docs))
- **galculator** – GTK calculator. ([docs](https://github.com/galculator/galculator))
- **git-delta** – Syntax-highlighting pager for Git diffs. ([docs](https://dandavison.github.io/delta/))
- **glow** – TUI Markdown viewer. ([docs](https://github.com/charmbracelet/glow))
- **gnome-keyring** – Password and key manager. ([docs](https://wiki.gnome.org/Projects/GnomeKeyring))
- **gparted** – Graphical partition manager. ([docs](https://gparted.org/))
- **gsimplecal** – Simple popup calendar. ([docs](https://dmedvinsky.github.io/gsimplecal/))
- **htop** – Interactive process viewer. ([docs](https://htop.dev/))
- **jq** – Command-line JSON processor. ([docs](https://jqlang.org/manual/))
- **kitty** – GPU-accelerated terminal emulator. ([docs](https://sw.kovidgoyal.net/kitty/))
- **lazygit** – TUI Git interface. ([docs](https://github.com/jesseduffield/lazygit))
- **libsecret** – Library for password/key storage. ([docs](https://github.com/GNOME/libsecret))
- **lsd** – `ls` replacement with icons and colors. ([docs](https://github.com/lsd-rs/lsd))
- **ncdu** – Disk usage analyzer. ([docs](https://dev.yorhel.nl/ncdu/man))
- **networkmanager-openvpn** – OpenVPN integration for NetworkManager. ([docs](https://wiki.archlinux.org/title/OpenVPN))
- **nodejs-lts-jod** – Long-term support version of Node.js. ([docs](https://nodejs.org/en/docs/))
- **npm** – Package manager for Node.js. ([docs](https://docs.npmjs.com/))
- **nvim** – Modern Vim-based editor with Lua support. ([docs](https://neovim.io/doc/))
- **obs-studio** – Video recording & streaming software. ([docs](https://obsproject.com/wiki/))
- **obsidian** – Markdown-based note-taking app. ([docs](https://help.obsidian.md/))
- **onefetch** – Git repository summary in terminal. ([docs](https://github.com/o2sh/onefetch))
- **ouch** – Compression and decompression tool with auto-format detection. ([docs](https://github.com/ouch-org/ouch))
- **picom** – X11 compositor for transparency & shadows. ([docs](https://wiki.archlinux.org/title/Picom))
- **playerctl** – Control media players from CLI. ([docs](https://github.com/altdesktop/playerctl))
- **qbittorrent** – BitTorrent client. ([docs](https://www.qbittorrent.org/))
- **redshift** – Adjusts screen color temperature. ([docs](https://wiki.archlinux.org/title/Redshift))
- **ripgrep** – Fast recursive search tool. ([docs](https://github.com/BurntSushi/ripgrep))
- **rustup** – Rust version manager. ([docs](https://rust-lang.github.io/rustup/))
- **seahorse** – GUI for GNOME Keyring. ([docs](https://wiki.gnome.org/Apps/Seahorse))
- **shotcut** – Free, open source, cross-platform video editor. ([docs](https://www.shotcut.org/))
- **spectacle** – KDE screenshot tool. ([docs](https://github.com/KDE/spectacle))
- **tabiew** – TUI tabular data viewer. ([docs](https://github.com/shshemi/tabiew))
- **tdf** – Terminal-based PDF viewer. ([docs](https://github.com/itsjunetime/tdf))
- **telegram-desktop** – Official Telegram client. ([docs](https://desktop.telegram.org/))
- **tor** – Anonymity network. ([docs](https://2019.www.torproject.org/docs/documentation.html.en))
- **torsocks** – Run applications through Tor. ([docs](https://gitweb.torproject.org/torsocks.git))
- **trash-cli** – CLI trash management. ([docs](https://github.com/andreafrancia/trash-cli))
- **tree** – Directory tree listing. ([docs](https://linux.die.net/man/1/tree))
- **ttf-jetbrains-mono-nerd** – JetBrains Mono font patched with Nerd Fonts symbols. ([docs](https://www.nerdfonts.com/font-downloads))
- **vim** – Highly configurable text editor. ([docs](https://www.vim.org/docs.php))
- **vulkan-icd-loader** – Vulkan driver loader. ([docs](https://github.com/KhronosGroup/Vulkan-Loader))
- **vulkan-radeon** – Vulkan driver for AMD GPUs. ([docs](https://docs.mesa3d.org/drivers/radv.html))
- **vulkan-tools** – Vulkan utilities. ([docs](https://vulkan.lunarg.com/doc/sdk/latest/linux/tools.html))
- **wine** – Run Windows apps on Linux. ([docs](https://wiki.winehq.org/))
- **xclip** – Clipboard tool for X11. ([docs](https://linux.die.net/man/1/xclip))
- **xsel** – Alternative clipboard tool for X11. ([docs](https://linux.die.net/man/1/xsel))
- **yt-dlp** – Video/audio downloader. ([docs](https://github.com/yt-dlp/yt-dlp))
- **zoxide** – Smarter `cd` command based on usage history. ([docs](https://github.com/ajeetdsouza/zoxide))

## Installed via yay (AUR)

- **anydesk-bin** – Remote desktop software. ([docs](https://anydesk.com))
- **bitchat-tui** – TUI chat application. ([docs](https://github.com/vaibhav-mattoo/bitchat-tui))
- **blobdrop-git** – Local network file sharing tool. ([docs](https://github.com/vimpostor/blobdrop))
- **bluetuith** – TUI Bluetooth manager. ([docs](https://bluetuith-org.github.io/bluetuith/index.html))
- **downloader-cli** – CLI file downloader. ([docs](https://github.com/deepjyoti30/downloader-cli))
- **dysk** – Utility listing your filesystems. ([docs](https://dystroy.org/dysk/))
- **fish-done** – Notifications for long-running commands in Fish. ([docs](https://github.com/franciscolourenco/done))
- **hellwal** – Wallpaper-based color scheme generator. ([docs](https://github.com/danihek/hellwal))
- **lazydocker** – TUI Docker manager. ([docs](https://github.com/jesseduffield/lazydocker))
- **mmtui** – TUI disk mounter for file managers. ([docs](https://github.com/SL-RU/mmtui))
- **nekoray-bin** – GUI for V2Ray/XRay tunneling. ([docs](https://github.com/MatsuriDayo/nekoray))
- **neohtop** – Improved htop clone. ([docs](https://github.com/Abdenasser/neohtop))
- **obfs4proxy** – Tor pluggable transport. ([docs](https://github.com/Yawning/obfs4))
- **onlyoffice-bin** – Office suite with MS Office format support. ([docs](https://help.onlyoffice.com/))
- **pantum-driver** – Printer driver for Pantum devices. ([docs](https://www.pantum.ru/support/drivers/))
- **portmaster-bin** – Firewall and network monitor. ([docs](https://safing.io/portmaster/))
- **portproton** – Proton/Wine launcher for Windows games. ([docs](https://linux-gaming.ru/))
- **rofi-bluetooth-git** – Bluetooth control via Rofi. ([docs](https://github.com/ClydeDroid/rofi-bluetooth))
- **rofi-games** – Rofi-based game launcher. ([docs](https://github.com/Rolv-Apneseth/rofi-games))
- **rofi-greenclip** – Clipboard manager for Rofi. ([docs](https://github.com/erebe/greenclip))
- **rudesktop** – Cross-platform RDP/VNC client. ([docs](https://rudesktop.ru/))
- **speedread-git** – CLI speed-reading tool. ([docs](https://github.com/pasky/speedread))
- **torbrowser-launcher** – Tor Browser installer/updater. ([docs](https://github.com/micahflee/torbrowser-launcher))
- **ventoy-bin** – Bootable USB multiboot creator. ([docs](https://www.ventoy.net/en/doc_start.html))
- **visual-studio-code-bin** – VS Code editor (binary from Microsoft). ([docs](https://code.visualstudio.com/docs))
- **whatsapp-linux-desktop** – Unofficial WhatsApp desktop client. ([docs](https://github.com/eneshecan/whatsapp-for-linux))
- **xautolock** – Idle-time screen locker. ([docs](https://linux.die.net/man/1/xautolock))
- **xkblayout-state-git** – Get/set X11 keyboard layout. ([docs](https://github.com/nonpop/xkblayout-state))
- **yandex-browser** – Yandex web browser. ([docs](https://browser.yandex.ru/help/))
- **yandex-disk** – Cloud storage client. ([docs](https://yandex.ru/support/yandex-360/customers/disk/desktop/linux))
- **yandex-music** – Unofficial Yandex Music client. ([docs](https://github.com/cucumber-sp/yandex-music-linux))
- **yazi-git** – Modern TUI file manager with Lua plugins. ([docs](https://yazi-rs.github.io/docs/quick-start))
- **ytsurf** – TUI YouTube browser/downloader. ([docs](https://github.com/Stan-breaks/ytsurf))

---

## **Installed via npm (global)**

- **@bramus/caniuse-cli** – Check browser support from the terminal. ([docs](https://github.com/bramus/caniuse-cli))
- **@google/gemini-cli** – Google Gemini AI CLI client. ([docs](https://github.com/google-gemini/gemini-cli))
- **npm-check-updates** – Check for newer npm dependencies. ([docs](https://github.com/raineorshine/npm-check-updates))
- **pnq** – Lightweight npm package query tool. ([docs](https://github.com/lirantal/npq))

---

## **Installed via pipx**

- **terminal-rain-lightning** – Animated rain & lightning in terminal. ([docs](https://github.com/rmaake1/terminal-rain-lightning))

---

## **Installed via curl script**

- **ggh** – Lightweight SSH wrapper tool. ([docs](https://github.com/byawitz/ggh))
