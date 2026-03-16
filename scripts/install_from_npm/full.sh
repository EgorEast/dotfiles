#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/main.sh"

sudo npm i -g \
  @builder.io/ai-shell \
  @openai/codex \
  live-server \
  ocx
