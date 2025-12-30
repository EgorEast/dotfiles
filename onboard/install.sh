#!/usr/bin/env bash
set -e

echo "Applying onboard dconf…"

# загрузка напрямую (без system db)
dconf load /org/onboard/ < \
  ~/.config/onboard/org.onboard.conf
