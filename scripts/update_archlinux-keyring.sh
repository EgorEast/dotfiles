#!/usr/bin/env bash

sudo pacman -Syy archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman-key --refresh-keys
sudo pacman -Syyuu && yay -Syu
