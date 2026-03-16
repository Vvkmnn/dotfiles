#!/usr/bin/env sh

# Location display - flag + country code when connected, slashed globe when not
# Uses ipinfo.io for geolocation, cached for 2 minutes
# Detects VPN by checking if default route interface changed (zero network cost)

WIFI_STATUS=$(ifconfig en0 2>/dev/null | grep 'status: active')
ETH_STATUS=$(ifconfig en1 2>/dev/null | grep 'status: active')

CACHE_FILE="/tmp/sketchybar_location"
CACHE_TTL=60

# Country code to flag emoji — pure sh
# Regional indicators U+1F1E6-U+1F1FF → UTF-8: F0 9F 87 [A6+offset]
country_to_flag() {
	local cc="$1"
	local i=1
	while [ $i -le ${#cc} ]; do
		local ch=$(echo "$cc" | cut -c$i)
		local val=$(printf '%d' "'$ch")
		local byte4=$((val + 101))  # 166 (0xA6) - 65 ('A') = 101
		printf "\xf0\x9f\x87\x$(printf '%02x' $byte4)"
		i=$((i + 1))
	done
}

get_network_fingerprint() {
	local route_info=$(route -n get default 2>/dev/null)
	local iface=$(echo "$route_info" | grep 'interface:' | awk '{print $2}')
	local gw=$(echo "$route_info" | grep 'gateway:' | sed 's/.*gateway: //')
	echo "${iface}|${gw}"
}

# Cache format: COUNTRY|FINGERPRINT (e.g. "AU|en0|192.168.1.1")
get_location() {
	local current_fp=$(get_network_fingerprint)

	if [ -f "$CACHE_FILE" ]; then
		local cached_fp=$(cut -d'|' -f2- "$CACHE_FILE")
		local CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE")))

		# Use cache if TTL valid AND network unchanged (no VPN switch)
		if [ "$CACHE_AGE" -lt "$CACHE_TTL" ] && [ "$current_fp" = "$cached_fp" ]; then
			cut -d'|' -f1 "$CACHE_FILE"
			return
		fi
	fi

	COUNTRY=$(curl -fsS --max-time 3 "https://ipinfo.io/country" 2>/dev/null | tr -d '[:space:]')
	if [ -n "$COUNTRY" ] && [ ${#COUNTRY} -eq 2 ]; then
		printf "%s|%s" "$COUNTRY" "$current_fp" >"$CACHE_FILE"
		printf "%s" "$COUNTRY"
	fi
}

if [ -n "$WIFI_STATUS" ] || [ -n "$ETH_STATUS" ]; then
	COUNTRY=$(get_location)
	if [ -n "$COUNTRY" ]; then
		FLAG=$(country_to_flag "$COUNTRY")
		sketchybar --set location icon="$FLAG" \
			icon.drawing=on \
			label="$COUNTRY" \
			label.drawing=on
	else
		# Connected but geo lookup failed
		sketchybar --set location icon="󰖟" \
			icon.drawing=on \
			label="" \
			label.drawing=off
	fi
else
	# Not connected
	sketchybar --set location icon="󰪎" \
		icon.drawing=on \
		label="" \
		label.drawing=off
fi
