#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

rm -rf ~/.config/mineapps.list

"$SCRIPT_DIR/main.sh"

stow --adopt --restow \
  anydesk \
  atac \
  autostart \
  cava \
  chawan \
  claude \
  clipse \
  cmus \
  dive \
  docker \
  galculator \
  gemini \
  github-cli \
  gtk \
  hledger \
  i3 \
  icons \
  inputrc \
  k9s \
  khal \
  lazydocker \
  lnav \
  ls-fusion \
  lynx \
  mailcap \
  mineapp-list \
  nwg-look \
  opencode \
  ovpn \
  pavucontrol \
  picom \
  pipewire \
  profanity \
  qalculate \
  redshift \
  rofi \
  rustdesk \
  scooter \
  screenlayout \
  ssh \
  sshm \
  taskwarrior \
  television \
  termscp \
  termshark \
  thunar \
  ttyper \
  user-dirs \
  warpd \
  wavemon \
  wget \
  xarchiver \
  xfce-4 \
  xinit \
  xorg \
  xsettingsd \
  ya-disk \
  ytsurf \
  -t ~
