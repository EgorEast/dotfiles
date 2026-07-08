#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/main.sh"

yay -S --noconfirm --needed \
  android-studio \
  anydesk-bin \
  balena-etcher \
  checkersland \
  clipse \
  flutter-bin \
  freetube-bin \
  kumir2-git \
  mmtui-bin \
  ocx \
  rmtrash \
  rofi-bluetooth-git \
  rofi-greenclip \
  rudesktop \
  rustdesk-bin \
  via-appimage \
  vial-appimage \
  warpd \
  wifitui-bin \
  xautolock \
  xkblayout-state-git \
  yandex-disk \
  ytsurf
