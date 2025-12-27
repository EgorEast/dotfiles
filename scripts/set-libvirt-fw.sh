#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/libvirt/network.conf"
KEY="firewall_backend"
VALUE="iptables"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

# есть строка (закомментированная или нет) — заменить и раскомментировать
if grep -Eq "^[[:space:]]*#?[[:space:]]*${KEY}[[:space:]]*=" "$CONF"; then
  sed -i -E "s|^[[:space:]]*#?[[:space:]]*${KEY}[[:space:]]*=.*|${KEY} = \"${VALUE}\"|" "$CONF"
else
  echo "${KEY} = \"${VALUE}\"" >>"$CONF"
fi
