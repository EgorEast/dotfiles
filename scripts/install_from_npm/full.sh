#!/usr/bin/env bash

SCRIPT_DIR="$HOME/.local/src/dotfiles/scripts/install_from_npm"

. "$SCRIPT_DIR/main.sh"

sudo npm i -g \
  @builder.io/ai-shell \
  live-server
