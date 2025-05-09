#!/usr/bin/env sh
# wifi.sh - Sketchybar Wi-Fi plugin

CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

# Removed local icon definitions, assuming $ICON_WIFI and $ICON_WIFI_OFF are sourced from icons.sh

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME label="Disconnected" icon="$ICON_WIFI_OFF"
else
  sketchybar --set $NAME label="$SSID (${CURR_TX}Mbps)" icon="$ICON_WIFI"
fi
