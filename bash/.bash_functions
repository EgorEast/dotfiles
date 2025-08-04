#!/usr/bin/env bash

# aliases
# function t() {
#   X=$#
#   [[ $X -eq 0 ]] || X=X
#   tmux new-session -A -s $X
#   tmux set-environment LC_ALL 'en_US.UTF-8'
#   tmux set-environment LANG 'en_US.UTF-8'
# }

npm() {
  if [[ "$1" == "i" || "$1" == "install" ]]; then
    shift
    npq install "$@"
  else
    command npm "$@"
  fi
}
