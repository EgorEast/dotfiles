#!/bin/bash
sudo openvpn \
  --config ~/ovpn/configs/crelcom_egoreast_crelcom_intro.ovpn \
  --auth-user-pass ~/ovpn/configs/crelcom_egoreast_crelcom_intro.txt \
  --script-security 2 \
  --down-pre

# sudo openvpn \
#   --config ~/.local/src/ovpn/crelcom_egoreast_crelcom_intro.ovpn \
#   --auth-user-pass ~/.local/src/vpn-auth.txt \
#   --script-security 2 \
#   --up /etc/openvpn/update-resolv-conf \
#   --down /etc/openvpn/update-resolv-conf \
#   --down-pre
