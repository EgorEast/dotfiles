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
- [setup kitty](#setupkitty)
- [apply xresources](#apply-xresources)
- [enable necessary services](#enable-necessary-services)
- [setup bandwhich](#setup-bandwhich)
- [setup env variables](#setup-env-variables)
- [about packages](#-about-packages)

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
 stow anydesk autostart bash calcurse cmus curl delta dunst fastfetch fish flameshot gemini git glow greenclip gtk i3 icons inputrc kitty lazygit mineapp-list mpv nano nekoray neovim nwg-look obs onlyoffice pavucontrol picom pipewire rofi rudesktop spectacle ssh thunar user-dirs vim wget xfce-4 xinit xorg xsettingsd ya-disk ya-music yazi yt-dlp ytsurf xarchiver galculator lazydocker redshift ncdu bluetuith lsd qalculate bat tg mailcap feh -t ~

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
sudo pacman -S vim nodejs-lts-jod npm kitty ttf-jetbrains-mono-nerd fish fisher nvim lazygit git-delta trash-cli zoxide ouch glow onefetch ripgrep xclip xsel cmus lsd playerctl jq gparted qbittorrent spectacle obs-studio networkmanager-openvpn yt-dlp shotcut redshift blueberry gsimplecal calcurse telegram-desktop libsecret gnome-keyring seahorse ddcutil firefox brightnessctl flameshot galculator tree fastfetch picom obsidian vulkan-radeon vulkan-tools vulkan-icd-loader cloc bat tabiew tor torsocks ncdu fd rustup tdf-git wine python-pipx libqalculate bandwhich urlview feh


yay -S yazi-git fish-done yandex-browser onlyoffice-bin portproton ventoy-bin pantum-driver yandex-disk visual-studio-code-bin xkblayout-state-git rofi-greenclip rudesktop anydesk-bin xautolock nekoray-bin whatsapp-linux-desktop ytsurf lazydocker dysk rofi-games portmaster-bin blobdrop-git bitchat-tui downloader-cli hellwal speedread-git torbrowser-launcher obfs4proxy yandex-music rofi-bluetooth-git bluetuith-bin mmtui-bin telegram-tg

sudo npm i -g npm-check-updates @bramus/caniuse-cli @google/gemini-cli pnq

pipx ensurepath
sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
pipx install git+https://github.com/rmaake1/terminal-rain-lightning.git

curl https://raw.githubusercontent.com/byawitz/ggh/master/install/unix.sh | sh
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

# setup bandwhich

```sh
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)
```

# setup env variables

```sh
sudo bash -c 'grep -q "EDITOR=" /etc/environment && sed -i "s/^EDITOR=.*$/EDITOR=nvim/" /etc/environment || echo "EDITOR=nvim" >> /etc/environment; grep -q "BROWSER=" /etc/environment && sed -i "s/^BROWSER=.*$/BROWSER=yandex-browser-stable/" /etc/environment || echo "BROWSER=yandex-browser-stable" >> /etc/environment; grep -q "VISUAL=" /etc/environment || echo "VISUAL=nvim" >> /etc/environment; awk "!seen[\$0]++ && NF" /etc/environment > /tmp/env.tmp && mv /tmp/env.tmp /etc/environment; echo -e "\nПроверка:\n$(cat /etc/environment)"'
```

# 📦 About packages

## 🖥 System Monitoring & Info

- **btop** – Interactive process viewer. ([docs](https://github.com/aristocratos/bashtop))
- **dysk** – Utility listing your filesystems. ([docs](https://dystroy.org/dysk/))
- **fastfetch** – Fast system info fetcher. ([docs](https://github.com/fastfetch-cli/fastfetch))
- **ncdu** – Disk usage analyzer. ([docs](https://dev.yorhel.nl/ncdu/man))

## 📂 File & Disk Management

- **gparted** – Graphical partition manager. ([docs](https://gparted.org/))
- **mmtui** – TUI disk mounter for file managers. ([docs](https://github.com/SL-RU/mmtui))
- **trash-cli** – CLI trash management. ([docs](https://github.com/andreafrancia/trash-cli))
- **tree** – Directory tree listing. ([docs](https://linux.die.net/man/1/tree))
- **ventoy-bin** – Bootable USB multiboot creator. ([docs](https://www.ventoy.net/en/doc_start.html))
- **yazi-git** – Modern TUI file manager with Lua plugins. ([docs](https://yazi-rs.github.io/docs/quick-start))

## 🌐 Networking & Communication

- **anydesk-bin** – Remote desktop software. ([docs](https://anydesk.com))
- **bandwhich** - CLI utility for displaying current network utilization by process, connection and remote IP/hostname. ([docs](https://github.com/imsnif/bandwhich))
- **bitchat-tui** – TUI chat application. ([docs](https://github.com/vaibhav-mattoo/bitchat-tui))
- **blobdrop-git** – Local network file sharing tool. ([docs](https://github.com/vimpostor/blobdrop))
- **firefox** – Web browser. ([docs](https://support.mozilla.org/))
- **nekoray-bin** – GUI for V2Ray/XRay tunneling. ([docs](https://github.com/MatsuriDayo/nekoray))
- **networkmanager-openvpn** – OpenVPN integration for NetworkManager. ([docs](https://wiki.archlinux.org/title/OpenVPN))
- **obfs4proxy** – Tor pluggable transport. ([docs](https://github.com/Yawning/obfs4))
- **portmaster-bin** – Firewall and network monitor. ([docs](https://safing.io/portmaster/))
- **rudesktop** – Cross-platform RDP/VNC client. ([docs](https://rudesktop.ru/))
- **telegram-desktop** – Official Telegram client. ([docs](https://desktop.telegram.org/))
- **telegram-tg** – Telegram terminal client. ([docs](https://github.com/paul-nameless/tg))
- **tor** – Anonymity network. ([docs](https://2019.www.torproject.org/docs/documentation.html.en))
- **torbrowser-launcher** – Tor Browser installer/updater. ([docs](https://github.com/micahflee/torbrowser-launcher))
- **torsocks** – Run applications through Tor. ([docs](https://gitweb.torproject.org/torsocks.git))
- **whatsapp-linux-desktop** – Unofficial WhatsApp desktop client. ([docs](https://github.com/eneshecan/whatsapp-for-linux))
- **yandex-browser** – Yandex web browser. ([docs](https://browser.yandex.ru/help/))
- **yandex-disk** – Cloud storage client. ([docs](https://yandex.ru/support/yandex-360/customers/disk/desktop/linux))

## 💻 Development Tools

- **@bramus/caniuse-cli** – Check browser support from the terminal. ([docs](https://github.com/bramus/caniuse-cli))
- **@google/gemini-cli** – Google Gemini AI CLI client. ([docs](https://github.com/google-gemini/gemini-cli))
- **cloc** – Count lines of code. ([docs](https://github.com/AlDanial/cloc))
- **fd** – Fast alternative to `find`. ([docs](https://github.com/sharkdp/fd))
- **ggh** – Lightweight SSH wrapper tool. ([docs](https://github.com/byawitz/ggh))
- **git-delta** – Syntax-highlighting pager for Git diffs. ([docs](https://dandavison.github.io/delta/))
- **lazydocker** – TUI Docker manager. ([docs](https://github.com/jesseduffield/lazydocker))
- **lazygit** – TUI Git interface. ([docs](https://github.com/jesseduffield/lazygit))
- **nodejs-lts-jod** – Long-term support version of Node.js. ([docs](https://nodejs.org/en/docs/))
- **npm** – Package manager for Node.js. ([docs](https://docs.npmjs.com/))
- **npm-check-updates** – Check for newer npm dependencies. ([docs](https://github.com/raineorshine/npm-check-updates))
- **nvim** – Modern Vim-based editor with Lua support. ([docs](https://neovim.io/doc/))
- **onefetch** – Git repository summary in terminal. ([docs](https://github.com/o2sh/onefetch))
- **pnq** – Lightweight npm package query tool. ([docs](https://github.com/lirantal/npq))
- **ripgrep** – Fast recursive search tool. ([docs](https://github.com/BurntSushi/ripgrep))
- **rustup** – Rust version manager. ([docs](https://rust-lang.github.io/rustup/))
- **vim** – Highly configurable text editor. ([docs](https://www.vim.org/docs.php))
- **visual-studio-code-bin** – VS Code editor. ([docs](https://code.visualstudio.com/docs))

## 🛠 System Utilities

- **bat** – `cat` replacement with syntax highlighting. ([docs](https://github.com/sharkdp/bat))
- **brightnessctl** – CLI brightness control. ([docs](https://github.com/Hummer12007/brightnessctl))
- **ddcutil** – Monitor settings control via DDC/CI. ([docs](https://www.ddcutil.com/))
- **kitty** – GPU-accelerated terminal emulator. ([docs](https://sw.kovidgoyal.net/kitty/))
- **lsd** – `ls` replacement with icons and colors. ([docs](https://github.com/lsd-rs/lsd))
- **xautolock** – Idle-time screen locker. ([docs](https://linux.die.net/man/1/xautolock))
- **xclip** – Clipboard tool for X11. ([docs](https://linux.die.net/man/1/xclip))
- **xkblayout-state-git** – Get/set X11 keyboard layout. ([docs](https://github.com/nonpop/xkblayout-state))
- **xsel** – Alternative clipboard tool for X11. ([docs](https://linux.die.net/man/1/xsel))
- **zoxide** – Smarter `cd` command based on usage history. ([docs](https://github.com/ajeetdsouza/zoxide))

## 🎨 UI & Desktop Enhancements

- **blueberry** – GUI Bluetooth manager. ([docs](https://github.com/linuxmint/blueberry))
- **bluetuith** – TUI Bluetooth manager. ([docs](https://bluetuith-org.github.io/bluetuith/index.html))
- **hellwal** – Wallpaper-based color scheme generator. ([docs](https://github.com/danihek/hellwal))
- **picom** – X11 compositor for transparency & shadows. ([docs](https://wiki.archlinux.org/title/Picom))
- **redshift** – Adjusts screen color temperature. ([docs](https://wiki.archlinux.org/title/Redshift))
- **rofi-bluetooth-git** – Bluetooth control via Rofi. ([docs](https://github.com/ClydeDroid/rofi-bluetooth))

## 📷 Media Tools

- **cmus** – Console music player. ([docs](https://cmus.github.io/))
- **feh** – X11 image viewer. ([docs](https://github.com/derf/feh))
- **flameshot** – Screenshot tool with annotation. ([docs](https://flameshot.org/docs))
- **obs-studio** – Video recording & streaming software. ([docs](https://obsproject.com/wiki/))
- **playerctl** – Control media players from CLI. ([docs](https://github.com/altdesktop/playerctl))
- **shotcut** – Cross-platform video editor. ([docs](https://www.shotcut.org/))
- **spectacle** – KDE screenshot tool. ([docs](https://github.com/KDE/spectacle))
- **timg** – Terminal image viewer. ([docs](https://github.com/hzeller/timg))
- **urlview** – Extract URLs from a text file and allow the user to select via a menu. ([docs](https://aur.archlinux.org/packages/urlview))
- **yandex-music** – Unofficial Yandex Music client. ([docs](https://github.com/cucumber-sp/yandex-music-linux))
- **yt-dlp** – Video/audio downloader. ([docs](https://github.com/yt-dlp/yt-dlp))
- **ytsurf** – TUI YouTube browser/downloader. ([docs](https://github.com/Stan-breaks/ytsurf))

## 📅 Productivity

- **calcurse** – TUI calendar and task manager. ([docs](https://github.com/lfos/calcurse))
- **galculator** – GTK calculator. ([docs](https://github.com/galculator/galculator))
- **glow** – TUI Markdown viewer. ([docs](https://github.com/charmbracelet/glow))
- **gsimplecal** – Simple popup calendar. ([docs](https://dmedvinsky.github.io/gsimplecal/))
- **libqalculate** - TUI calculator. ([docs](https://github.com/Qalculate/libqalculate))
- **obsidian** – Markdown-based note-taking app. ([docs](https://help.obsidian.md/))
- **onlyoffice-bin** – Office suite with MS Office support. ([docs](https://help.onlyoffice.com/))
- **tabiew** – TUI tabular data viewer. ([docs](https://github.com/shshemi/tabiew))
- **tdf** – Terminal-based PDF viewer. ([docs](https://github.com/itsjunetime/tdf))

## 🎮 Gaming & Entertainment

- **portproton** – Proton/Wine launcher for Windows games. ([docs](https://linux-gaming.ru/))
- **rofi-games** – Rofi-based game launcher. ([docs](https://github.com/Rolv-Apneseth/rofi-games))
- **wine** – Run Windows apps on Linux. ([docs](https://wiki.winehq.org/))

## 🛡 Security & Encryption

- **gnome-keyring** – Password and key manager. ([docs](https://wiki.gnome.org/Projects/GnomeKeyring))
- **libsecret** – Library for password/key storage. ([docs](https://github.com/GNOME/libsecret))
- **seahorse** – GUI for GNOME Keyring. ([docs](https://wiki.gnome.org/Apps/Seahorse))

## 🖼 Fonts & Graphics

- **ttf-jetbrains-mono-nerd** – JetBrains Mono font patched with Nerd Fonts symbols. ([docs](https://www.nerdfonts.com/font-downloads))

## 📦 Miscellaneous & Fun

- **downloader-cli** – CLI file downloader. ([docs](https://github.com/deepjyoti30/downloader-cli))
- **fish** – User-friendly shell with autosuggestions. ([docs](https://fishshell.com/docs/current/))
- **fish-done** – Notifications for long-running commands in Fish. ([docs](https://github.com/franciscolourenco/done))
- **ouch** – Compression and decompression tool. ([docs](https://github.com/ouch-org/ouch))
- **speedread-git** – CLI speed-reading tool. ([docs](https://github.com/pasky/speedread))
- **terminal-rain-lightning** – Animated rain & lightning in terminal. ([docs](https://github.com/rmaake1/terminal-rain-lightning))
