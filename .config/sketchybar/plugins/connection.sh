#!/usr/bin/env sh

# Connection quality — two-hop diagnostic
# 1. Ping default gateway (local network quality)
# 2. Ping internet (1.1.1.1 → 8.8.8.8 → 9.9.9.9 fallback)
# Display: smoothed internet ping
# Color: red = local network bad (switch!), orange = ISP issue, white = good

WIFI_STATUS=$(ifconfig en0 2>/dev/null | grep 'status: active')
ETH_STATUS=$(ifconfig en1 2>/dev/null | grep 'status: active')

WIFI_1="󰤟"  # weak (<-70 dBm)
WIFI_2="󰤢"  # fair (-60 to -70)
WIFI_3="󰤥"  # good (-50 to -60)
WIFI_4="󰤨"  # strong (>-50 dBm)
WIFI_OFF="󰤭"
ETH_ICON="󰈀"

WHITE=0xffFFFFFF
ORANGE=0xffFFA500
RED=0xffE74C3C
DIM=0xff8A869E

EMA_FILE="/tmp/sketchybar_ping_ema"
IFACE_FILE="/tmp/sketchybar_iface"
EMA_WEIGHT=30

# Single ping, return ms float or empty
ping_host() {
	ping -c1 -t2 "$1" 2>/dev/null | grep 'time=' | sed 's/.*time=\([0-9.]*\).*/\1/'
}

# 3 pings to first reachable target, return median
ping_internet() {
	# Fallback chain: Cloudflare → Google → Quad9
	for target in 1.1.1.1 8.8.8.8 9.9.9.9; do
		local times=$(ping -c3 -t3 "$target" 2>/dev/null | grep 'time=' | sed 's/.*time=\([0-9.]*\).*/\1/' | sort -n)
		local count=$(echo "$times" | wc -l | tr -d ' ')
		if [ "$count" -ge 2 ]; then
			echo "$times" | sed -n '2p'
			return
		elif [ "$count" -eq 1 ] && [ -n "$times" ]; then
			echo "$times"
			return
		fi
	done

	# TCP fallback if all ICMP blocked (e.g. China GFW)
	# Connect to DNS port 53, measure time
	for target in 1.1.1.1 8.8.8.8 9.9.9.9; do
		local tcp_ms=$( (TIMEFORMAT='%3R'; time nc -z -w2 "$target" 53) 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
		if [ -n "$tcp_ms" ]; then
			# Convert seconds to ms
			local ms_int=$(awk -v t="$tcp_ms" 'BEGIN{printf "%d", t*1000}')
			[ -n "$ms_int" ] && echo "$ms_int" && return
		fi
	done
}

apply_ema() {
	local current_int=$(printf '%.0f' "$1" 2>/dev/null)
	if [ -f "$EMA_FILE" ]; then
		local prev=$(cat "$EMA_FILE")
		local smoothed=$(( (EMA_WEIGHT * current_int + (100 - EMA_WEIGHT) * prev) / 100 ))
		echo "$smoothed" > "$EMA_FILE"
		echo "$smoothed"
	else
		echo "$current_int" > "$EMA_FILE"
		echo "$current_int"
	fi
}

get_wifi_icon() {
	local RSSI=$("$HOME/.config/sketchybar/helpers/wifi-signal" 2>/dev/null)
	if [ -n "$RSSI" ] && [ "$RSSI" -lt 0 ]; then
		if [ "$RSSI" -gt -50 ]; then echo "$WIFI_4"
		elif [ "$RSSI" -gt -60 ]; then echo "$WIFI_3"
		elif [ "$RSSI" -gt -70 ]; then echo "$WIFI_2"
		else echo "$WIFI_1"
		fi
	else
		echo "$WIFI_4"
	fi
}

# Detect network change (interface OR gateway) → trigger location refresh
ROUTE_INFO=$(route -n get default 2>/dev/null)
CURRENT_IFACE=$(echo "$ROUTE_INFO" | awk '/interface:/{print $2}')
CURRENT_GW=$(echo "$ROUTE_INFO" | awk '/gateway:/{print $2}')
CURRENT_NET="${CURRENT_IFACE}|${CURRENT_GW}"
if [ -f "$IFACE_FILE" ]; then
	PREV_NET=$(cat "$IFACE_FILE")
	if [ "$CURRENT_NET" != "$PREV_NET" ]; then
		sketchybar --trigger network_change
	fi
fi
echo "$CURRENT_NET" > "$IFACE_FILE"

if [ -n "$WIFI_STATUS" ] || [ -n "$ETH_STATUS" ]; then
	if [ -n "$WIFI_STATUS" ]; then
		ICON=$(get_wifi_icon)
	else
		ICON="$ETH_ICON"
	fi

	# Gateway ping (local network check) — reuse CURRENT_GW from route call above
	GW_MS=""
	[ -n "$CURRENT_GW" ] && GW_MS=$(ping_host "$CURRENT_GW")

	# Internet ping
	INET_MS=$(ping_internet)

	if [ -n "$INET_MS" ]; then
		PING=$(apply_ema "$INET_MS")
		LABEL="${PING}ms"

		# Color: gateway problem → red, internet slow → orange, all good → white
		GW_INT=$(printf '%.0f' "$GW_MS" 2>/dev/null)
		if [ -n "$GW_INT" ] && [ "$GW_INT" -gt 50 ]; then
			COLOR=$RED
		elif [ "$PING" -lt 30 ]; then
			COLOR=$WHITE
		elif [ "$PING" -lt 100 ]; then
			COLOR=$ORANGE
		else
			COLOR=$RED
		fi
	else
		LABEL="--"
		COLOR=$DIM
		rm -f "$EMA_FILE"
	fi

	sketchybar --set connection icon="$ICON" \
		icon.drawing=on \
		icon.color=$COLOR \
		label="$LABEL" \
		label.color=$COLOR \
		label.drawing=on
else
	# No internet — hide entirely (location shows slashed globe)
	rm -f "$EMA_FILE"
	sketchybar --set connection icon.drawing=off \
		label.drawing=off
fi
