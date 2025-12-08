#!/bin/bash

CALDIR="$HOME/.calcurse"

while inotifywait -r -e modify,create,delete "$CALDIR"; do
  pkill -f "calcurse --daemon"
  calcurse -C "$CALDIR" --daemon &
done
