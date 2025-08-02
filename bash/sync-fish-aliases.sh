#!/bin/bash

INPUT="$HOME/.config/fish/config.fish"
OUTPUT="$HOME/.bash_aliases"

echo "# Auto-generated from \$HOME/.config/fish/config.fish" >"$OUTPUT"

grep '^alias ' "$INPUT" | while read -r line; do
  # Извлечь имя алиаса и команду
  name=$(echo "$line" | sed -E "s/alias\s+([^=]+)=.*/\1/")
  cmd=$(echo "$line" | sed -E "s/alias\s+[^=]+='(.*)'/\1/" | sed -E 's/\\"/"/g')

  echo "alias $name='$cmd'" >>"$OUTPUT"
done
