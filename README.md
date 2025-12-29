# EgorEast's dotfiles

```txt
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

### table of contents

- [managing](#managing)
- [installing](#installing)
- [how it works](#how-it-works)
- [script for install and setup packages](#script-for-install-and-setup-packages)
- [my dotfiles setup](#my-dotfiles-setup)
- [tl;dr](#tldr)
- [setup kitty](#setupkitty)
- [apply xresources](#apply-xresources)
- [enable necessary services](#enable-necessary-services)
- [setup bandwhich](#setup-bandwhich)
- [about packages](#-about-packages)

## managing

i manage mine with [gnu stow](http://www.gnu.org/software/stow/), a free, portable, lightweight symlink farm manager. this allows me to keep a versioned directory of all my config files that are virtually linked into place via a single command. this makes sharing these files among many users (root) and computers super simple. and does not clutter your home directory with version control files.

## installing

stow is available for all linux and most other unix like distributions via your package manager.

- `apt install stow`
- `brew install stow`
- `dnf install stow`
- `pacman -S stow`
- `yum install stow`

or clone it [from source](https://savannah.gnu.org/git/?group=stow) and [build it](http://git.savannah.gnu.org/cgit/stow.git/tree/INSTALL) yourself.

## how it works

by default the stow command will create symlinks for files in the parent directory of where you execute the command. since i keep my dots in: `~/.local/src/dotfiles` and all stow commands should be executed in that directory and suffixed with `-t ~` to target the home directory. otherwise they will end up in `~/.local/`.

to install configs execute the stow command with the folder name as the first argument, then target your home directory (or wherever you like).

to install my **fish** configs use the command:

`stow fish -t ~`

this will symlink files like `config.fish` to `~/.config/fish`

**note:** stow can only create a symlink if a config file does not already exist. if a default file was created upon program installation you must delete it first before you can install a new one with stow. this does not apply to directories, only files.

## my dotfiles setup

to fully "install" and setup this repo run the [setup script](https://codeberg.org/egoreast/dotfiles/src/branch/main/setup.sh) or something like this:

```sh
# clone and stow
git clone ssh://git@codeberg.org/egoreast/dotfiles.git ~/.local/src/dotfiles &&
 cd ~/.local/src/dotfiles &&
 stow bash calcurse cmus curl delta dunst fastfetch -t ~

# nvim
nvim --headless "+Lazy! sync" +qa
nvim --headless "+Lazy! load mason.nvim" "+lua require('mason.api.command').MasonUpdate()" +qa
```

## tl;dr

navigate to your home directory

`cd ~`

clone the repo:

`git clone ssh://git@codeberg.org/egoreast/dotfiles.git`

enter the dotfiles directory

`cd dotfiles`

install the fish settings

`stow fish`

install fish settings for the root user

`sudo stow fish -t /root`

uninstall fish

`stow -D fish`

etc, etc, etc...

## setup kitty

```sh
sudo ln -sf /usr/bin/kitty /usr/bin/x-terminal-emulator
```

## apply xresources

```sh
cp ~/evangelion.Xresources ~/.Xresources
xrdb -merge ~/.Xresources
```

## enable necessary services

```sh
sudo systemctl enable --now reflector.timer

sudo systemctl start bluetooth
sudo systemctl enable bluetooth

yandex-disk token
yandex-disk start

```

## setup bandwhich

```sh
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(command -v bandwhich)
```

## 📦 About packages

About packages can be found [this page](https://codeberg.org/egoreast/dotfiles/src/branch/main/AboutPackages.md)
