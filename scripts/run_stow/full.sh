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
  iamb \
  icons \
  inputrc \
  k9s \
  khal \
  lazydocker \
  lazysql \
  lnav \
  ls-fusion \
  lynx \
  mailcap \
  mineapp-list \
  nsnake \
  nwg-look \
  nyaa \
  opencode \
  otter-launcher \
  ovpn \
  patat \
  pavucontrol \
  picom \
  pipewire \
  posting \
  profanity \
  qalculate \
  redshift \
  rofi \
  rustdesk \
  sc-im \
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
