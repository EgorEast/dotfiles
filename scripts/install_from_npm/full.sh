#!/usr/bin/env bash

SCRIPT_DIR="$HOME/.local/src/dotfiles/scripts"

. "$SCRIPT_DIR/main.sh"

sudo npm i -g \
  @builder.io/ai-shell \
  live-server
