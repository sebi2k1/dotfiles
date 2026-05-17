#!/bin/bash

# U+F1EB nf-fa-wifi, U+F6FF nf-fa-network-wired
WIFI=$(printf '\xef\x87\xab')
ETH=$(printf '\xef\x9b\xbf')

IFACE=$(route get default 2>/dev/null | awk '/interface/{print $2}')

if [ -z "$IFACE" ]; then
  echo "#[fg=#FF5555]offline"
  exit 0
fi

IP=$(ipconfig getifaddr "$IFACE" 2>/dev/null)
CACHE="/tmp/.tmux_nettype_$IFACE"

# Cache interface type for 5 minutes — networksetup is slow
if [ ! -f "$CACHE" ] || [ $(( $(date +%s) - $(stat -f %m "$CACHE") )) -gt 300 ]; then
  WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{f=1} f && /Device/{print $2; exit}')
  [ "$IFACE" = "$WIFI_DEV" ] && echo "wifi" > "$CACHE" || echo "eth" > "$CACHE"
fi

TYPE=$(cat "$CACHE")
[ "$TYPE" = "wifi" ] && SYM="$WIFI" || SYM="$ETH"

[ -n "$IP" ] && echo "${SYM} ${IP}" || echo "#[fg=#FF5555]${SYM} --"
